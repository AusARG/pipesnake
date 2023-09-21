import argparse
import pandas as pd
import os

"""
Ian Brennan
created on 7 June 2023
Written assuming: NA

Run it locally:
$ python ../BPA_process_metadata.py --pmf package_metadata/package_metadata_bpa…  --rmf resource_metadata/resource_metadata_bpa…
"""

def get_args():
    parser = argparse.ArgumentParser(
        description= "(1) Deduplicate reads using BBMap and dedupe"
                "(2) Trim Illumina reads for adaptor contamination "
                "low quality bases and merge reads.\n (3) Then filter "
                "reads using BBMap",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
        )

    # sample
    parser.add_argument(
        '--pmf',
        type=str,
        default=None,
        help='package metadata file.'
        )

        # sample
    parser.add_argument(
        '--rmf',
        type=str,
        default=None,
        help='resource metadata file.'
        )

        # sequence for adaptor 1
    parser.add_argument(
        '--adaptor1',
        type=str,
        default="GATCGGAAGAGCACACGTCTGAACTCCAGTCAC*ATCTCGTATGCCGTCTTCTGCTTG",
        help='sequence for adaptor 1 with position of barcode replaced by *. Only change this if you mean it.'
        )

        # sequence for adaptor 2
    parser.add_argument(
        '--adaptor2',
        type=str,
        default="AATGATACGGCGACCACCGAGATCTACAC*ACACTCTTTCCCTACACGACGCTCTTCCGATCT",
        help='sequence for adaptor 2 with position of barcode replaced by *. Only change this if you mean it.'
        )

        # directory holding the data, absolute path for 
    parser.add_argument(
        '--indir',
        type=str,
        default="/scratch/pawsey0862/[USER]/",
        help='full path for the directory holding the primary data. This is probably something like /scratch/pawsey0862/[USER_NAME]/[PROJECT_NAME].'
        )

    return parser.parse_args()

def process_bpa_metadata(args):
    # Read package metadata from CSV
    package_metadata = pd.read_csv(args.pmf)
    
    # Read resource metadata from CSV
    resource_metadata = pd.read_csv(args.rmf)
    
    resource_metadata['sample_id'] = resource_metadata['Name'].apply(lambda x: x.split('_')[0])
    package_metadata['sample_id'] = package_metadata['library_id'].apply(lambda x: x.split('/')[1])
    
    resource_metadata['File size (mb)'] = resource_metadata['File size (bytes)'] / 1000000
    
    agg_rm = resource_metadata.groupby('sample_id')['File size (mb)'].sum().reset_index()
    agg_rm.columns = ['sample_id', 'total file size (mb)']
    
    pm_rm = package_metadata.merge(agg_rm, on='sample_id', how='inner')
    pm_rm['total file size (gb)'] = pm_rm['total file size (mb)'] / 1000
    
    # Write pm_rm to CSV
    pm_rm.to_csv("BPA_combined_metadata.csv", index=False)

    # return pm_rm object
    return pm_rm


def BPA_sample_info(args):
    indir = args.indir
    # Read in the names of the sequence files
    seq_files = pd.read_csv(args.rmf)["Name"]
    
    # Create a dataframe after cleaning the information
    file_ids = pd.DataFrame({
        "filename": seq_files,
        "sample_id": seq_files.apply(lambda x: x.split("_")[0]),
        "barcode": seq_files.apply(lambda x: x.split("_")[4]),  # was [2]
        "sample_no": seq_files.apply(lambda x: x.split("_")[5]),  # was [3]
        "lane_no": seq_files.apply(lambda x: x.split("_")[6]),  # was [4]
        "direction": seq_files.apply(lambda x: x.split("_")[7])  # was [7]
    })

    # Read in the sample metadata file
    info = pd.read_csv(args.pmf)
    info["sample_id"] = info["library_id"].apply(lambda x: x.split("/")[1])
    info["specimen_id"] = info["specimen_id"].str.replace(" ", "_")
    info = info[["library_id", "genus", "species", "specimen_id", "library_index_seq", "library_index_seq_dual", "sample_id"]]
    #info.rename(columns={"library_index_seq": "library_index_seq_P7", "library_index_seq_dual": "library_index_seq_P5"}, inplace=True)
    
    # Create a column for the sample info
    info["lineage"] = info["genus"] + "_" + info["species"] + "_" + info["specimen_id"]
    info["adaptor1"] = args.adaptor1
    info["adaptor2"] = args.adaptor2
    
    # Split files into two dataframes to merge later
    file_ids_f = file_ids[file_ids["direction"] == "R1"]
    file_ids_r = file_ids[file_ids["direction"] == "R2"]
    
    # Get the appropriate barcodes
    file_ids_f["barcode"] = file_ids_f["sample_id"].apply(lambda x: info.loc[info["sample_id"] == x, "library_index_seq"].values[0])
    file_ids_r["barcode"] = file_ids_r["sample_id"].apply(lambda x: info.loc[info["sample_id"] == x, "library_index_seq_dual"].values[0])
    
    # Get the appropriate adaptors
    file_ids_f["adaptor"] = args.adaptor1
    file_ids_r["adaptor"] = args.adaptor2
    
    # Get the appropriate lineages
    file_ids_f["lineage"] = file_ids_f["sample_id"].apply(lambda x: info.loc[info["sample_id"] == x, "lineage"].values[0])
    file_ids_r["lineage"] = file_ids_r["sample_id"].apply(lambda x: info.loc[info["sample_id"] == x, "lineage"].values[0])
    
    # Combine the f/r file info together
    file_id_combo = pd.concat([file_ids_f, file_ids_r])
    file_id_combo = file_id_combo[["filename", "sample_id", "direction", "lane_no", "barcode", "adaptor", "lineage"]]
    
    # Write the file_id_combo to file
    file_id_combo.to_csv("BPA_ReadFileInfo.csv", index=False)
    
    # Determine the number of lanes and samples
    no_lanes = file_id_combo["lane_no"].unique()
    no_samps = file_id_combo["sample_id"].unique()
    
    # Create an empty sample info dataframe
    samp_info = pd.DataFrame()
    
    # Run a loop across the file_id_combo file making a traditional sample_info.csv file
    for lane in no_lanes:
        curr_lane = file_id_combo[file_id_combo["lane_no"] == lane]
        for samp in no_samps:
            curr_samp = curr_lane[curr_lane["sample_id"] == samp]
            samp_info = samp_info.append({
                "sample_id": samp,
                "read1": os.path.join(indir, curr_samp.loc[curr_samp["direction"] == "R1", "filename"].values[0]),
                "read2": os.path.join(indir, curr_samp.loc[curr_samp["direction"] == "R2", "filename"].values[0]),
                "barcode1": curr_samp.loc[curr_samp["direction"] == "R1", "barcode"].values[0],
                "barcode2": curr_samp.loc[curr_samp["direction"] == "R2", "barcode"].values[0],
                "adaptor1": args.adaptor1,
                "adaptor2": args.adaptor2,
                "lineage": curr_samp["lineage"].values[0]
            }, ignore_index=True)
    #samp_info['read1'] = args.indir + "/" + samp_info['read1']
    # Write the sample info dataframe to file
    samp_info.to_csv("BPA_SampleInfo.csv", index=False)



# Retrieve command-line arguments
args = get_args()

# Call the function with the provided arguments
process_bpa_metadata(args)

# call the function with the provided arguments
BPA_sample_info(args)
