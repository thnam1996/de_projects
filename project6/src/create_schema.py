from google.cloud import bigquery
from google.api_core.exceptions import NotFound


# Config setup


project_id='de-nam-lab'
dataset_id='raw_glamira'
client = bigquery.Client(project=project_id)


def get_or_create_dataset(client,project_id,dataset_id,table_id):
    dataset_ref=bigquery.Dataset(f"{project_id}.{dataset_id}")
    try:
        client.get_dataset(dataset_ref)
        print(f"[Info] Đã kết nối dataset{dataset_id}")
    except NotFound:
        dataset_ref.location="asia-southeast1"
        client.create_dataset(dataset_ref)
        print(f"[Info] Đã tạo dataset {dataset_id}")



# Scheme table 'summary'


table_id='summary'
def create_summary_table(client,project_id,dataset_id,table_id):
    get_or_create_dataset(client,project_id,dataset_id,table_id)
    table_ref=bigquery.Table(f"{project_id}.{dataset_id}.{table_id}")
    schema=[     
    bigquery.SchemaField("_id","STRING"),
    bigquery.SchemaField("api_version","STRING"),
    bigquery.SchemaField("cat_id","STRING"),
    bigquery.SchemaField("collect_id","STRING"),
    bigquery.SchemaField("collection","STRING"),
    bigquery.SchemaField("currency","STRING"),
    bigquery.SchemaField("current_url","STRING"),
    bigquery.SchemaField("device_id","STRING"),
    bigquery.SchemaField("email_address","STRING"),
    bigquery.SchemaField("ip","STRING"),
    bigquery.SchemaField("is_paypal","STRING"),
    bigquery.SchemaField("key_search","STRING"),
    bigquery.SchemaField("local_time","STRING"),
    bigquery.SchemaField("order_id","STRING"),
    bigquery.SchemaField("price","STRING"),
    bigquery.SchemaField("product_id","STRING"),
    bigquery.SchemaField("recommendation","BOOL"),
    bigquery.SchemaField("recommendation_clicked_position","STRING"),
    bigquery.SchemaField("recommendation_product_id","STRING"),
    bigquery.SchemaField("recommendation_product_position","STRING"),
    bigquery.SchemaField("referrer_url","STRING"),
    bigquery.SchemaField("resolution","STRING"),
    bigquery.SchemaField("show_recommendation","STRING"),
    bigquery.SchemaField("store_id","STRING"),
    bigquery.SchemaField("time_stamp","INT64"),
    bigquery.SchemaField("user_agent","STRING"),
    bigquery.SchemaField("user_id_db","STRING"),
    bigquery.SchemaField("utm_medium","STRING"),
    bigquery.SchemaField("utm_source","STRING"),
    bigquery.SchemaField("viewing_product_id","STRING"),

    # NESTED: option (top-level)
    bigquery.SchemaField(
    "option",
    "RECORD",
    mode="REPEATED",
    fields=[
    bigquery.SchemaField("Kollektion", "STRING"),
    bigquery.SchemaField("alloy", "STRING"),
    bigquery.SchemaField("category_id", "STRING"),  # từ "category id"
    bigquery.SchemaField("diamond", "STRING"),
    bigquery.SchemaField("finish", "STRING"),
    bigquery.SchemaField("kollektion_id", "STRING"),
    bigquery.SchemaField("option_id", "STRING"),
    bigquery.SchemaField("option_label", "STRING"),
    bigquery.SchemaField("pearlcolor", "STRING"),
    bigquery.SchemaField("price", "STRING"),
    bigquery.SchemaField("quality", "STRING"),
    bigquery.SchemaField("quality_label", "STRING"),
    bigquery.SchemaField("shapediamond", "STRING"),
    bigquery.SchemaField("stone", "STRING"),
    bigquery.SchemaField("value_id", "STRING"),
    bigquery.SchemaField("value_label", "STRING"),
    ],
    ),

    # NESTED: cart_products
    bigquery.SchemaField(
    "cart_products",
    "RECORD",
    mode="REPEATED",
            fields=[
            bigquery.SchemaField("product_id", "STRING"),
            bigquery.SchemaField("amount", "INT64"),
            bigquery.SchemaField("price", "STRING"),
            bigquery.SchemaField("currency", "STRING"),
            
    bigquery.SchemaField(
    "option",
    "RECORD",
    mode="REPEATED",
            fields=[
            bigquery.SchemaField("option_id", "STRING"),
            bigquery.SchemaField("option_label", "STRING"),
            bigquery.SchemaField("value_id", "STRING"),
            bigquery.SchemaField("value_label", "STRING"),
            ],
    ),
    ],
    ),
    ]
    table_ref.schema=schema
    
    try:
        client.get_table(table_ref)
        print(f"Done table {table_id}")
    except NotFound:
        client.create_table(table_ref)
        print(f"Finish create {table_id}")
        



# Scheme table 'ip_location'


table_id='ip_location'



def create_ip_location_table(client,project_id,dataset_id,table_id):
    get_or_create_dataset(client,project_id,dataset_id,table_id)
    table_ref=bigquery.Table(f"{project_id}.{dataset_id}.{table_id}")
    schema=[     
    bigquery.SchemaField("ip","STRING"),
    bigquery.SchemaField("status","STRING"),
    bigquery.SchemaField("country_short","STRING"),
    bigquery.SchemaField("country_long","STRING"),
    bigquery.SchemaField("region","STRING"),
    bigquery.SchemaField("city","STRING")
    ]
    table_ref.schema=schema
    
    try:
        client.get_table(table_ref)
        print(f"Done table {table_id}")
    except NotFound:
        client.create_table(table_ref)
        print(f"Finish create {table_id}")
        



# Scheme table 'product_infor'


def create_product_infor_table(client, project_id, dataset_id, table_id=table_id):

    get_or_create_dataset(client, project_id, dataset_id, table_id)

    table_ref = bigquery.Table(f"{project_id}.{dataset_id}.{table_id}")

    schema = [
        bigquery.SchemaField("product_id", "INT64"),
        bigquery.SchemaField("url", "STRING"),

        # ==== WANTED KEYS — ALL STRING ====
        bigquery.SchemaField("name", "STRING"),
        bigquery.SchemaField("sku", "STRING"),
        bigquery.SchemaField("attribute_set_id", "STRING"),
        bigquery.SchemaField("attribute_set", "STRING"),

        bigquery.SchemaField("type_id", "STRING"),
        bigquery.SchemaField("price", "STRING"),
        bigquery.SchemaField("min_price", "STRING"),
        bigquery.SchemaField("max_price", "STRING"),

        bigquery.SchemaField("min_price_format", "STRING"),
        bigquery.SchemaField("max_price_format", "STRING"),

        bigquery.SchemaField("gold_weight", "STRING"),
        bigquery.SchemaField("none_metal_weight", "STRING"),
        bigquery.SchemaField("fixed_silver_weight", "STRING"),

        bigquery.SchemaField("material_design", "STRING"),
        bigquery.SchemaField("qty", "STRING"),  # có thể đổi INT64 nếu chắc chắn là số
        bigquery.SchemaField("collection", "STRING"),
        bigquery.SchemaField("collection_id", "STRING"),

        bigquery.SchemaField("product_type", "STRING"),
        bigquery.SchemaField("product_type_value", "STRING"),

        bigquery.SchemaField("category", "STRING"),
        bigquery.SchemaField("category_name", "STRING"),
        bigquery.SchemaField("store_code", "STRING"),

        bigquery.SchemaField("platinum_palladium_info_in_alloy", "STRING"),
        bigquery.SchemaField("bracelet_without_chain", "STRING"),
        bigquery.SchemaField("show_popup_quantity_eternity", "STRING"),
        bigquery.SchemaField("visible_contents", "STRING"),
        bigquery.SchemaField("gender", "STRING"),
        bigquery.SchemaField("configure_mode", "STRING"),
        bigquery.SchemaField("included_chain_weight", "STRING"),
    ]

    table_ref.schema = schema

    try:
        client.get_table(table_ref)
        print(f"Done table {table_id}")
    except NotFound:
        client.create_table(table_ref)
        print(f"Finish create {table_id}")

if __name__=="__main__":
    create_summary_table(client,project_id,dataset_id,'summary')
    create_ip_location_table(client,project_id,dataset_id,'ip_location')
    create_product_infor_table(client, project_id, dataset_id, 'product_infor')




