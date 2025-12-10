###table summary
gcloud functions deploy gcs_to_bq_summary   
--gen2   
--runtime=python311 
--region=asia-southeast1   
--source=.   
--entry-point=summary_bq   
--trigger-bucket=raw_summary   
--set-env-vars=PROJECT_ID=de-nam-lab,DATASET_ID=raw_glamira,TABLE_ID=summary


###table ip_location
gcloud functions deploy gcs_to_bq_summary   
--gen2   
--runtime=python311 
--region=asia-southeast1   
--source=.   
--entry-point=summary_bq   
--trigger-bucket=raw_summary   
--set-env-vars=PROJECT_ID=de-nam-lab,DATASET_ID=raw_glamira,TABLE_ID=ip_location

###table product_infors
gcloud functions deploy gcs_to_bq_productinfor
--gen2   
--runtime=python311 
--region=asia-southeast1   
--source=.   
--entry-point=productinfor_bq   
--trigger-bucket=raw_product_infors  
--set-env-vars=PROJECT_ID=de-nam-lab,DATASET_ID=raw_glamira,TABLE_ID=product_infor
