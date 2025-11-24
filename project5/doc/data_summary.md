# Data Definition – countly.summary

- **Database:** countly → summary  
- **Size:** 31.2 GB  
- **Documents:** ~41 million  

## Field Definition Table (sample=100k)

| Field | Types | InArray | Sample_count | Col_present | Value_Null_percent | Example_5 |
| --- | --- | --- | --- | --- | --- | --- |
| _id | objectId | false | 100000 | 100.00% | 0.00% | "5ec7f8d25c503836d6b9b6e3", "5ec3caa771a3b936be77fb51", "5eceadab56b3dd37421978ca", "5ec6c1905c503836d6b8220b", "5ecfecef56b3dd37421aff2e" |
| time_stamp | number | false | 100000 | 100.00% | 0.00% | 1590163667, 1589889703, 1590603179, 1590083984, 1590684912 |
| ip | string | false | 100000 | 100.00% | 0.00% | "65.131.71.239", "187.162.75.140", "188.61.184.130", "187.144.223.104", "86.13.155.116" |
| user_agent | string | false | 100000 | 100.00% | 0.00% | "Mozilla/5.0 ...", "Mozilla/5.0 ...", "Mozilla/5.0 ..." |
| resolution | string | false | 100000 | 100.00% | 0.00% | "412x869", "412x846", "1920x1080", "375x812", "414x896" |
| user_id_db | string | false | 100000 | 100.00% | 0.00% | "", "403597", "485712", "503031", "483455" |
| device_id | string | false | 100000 | 100.00% | 0.00% | "2dd2ce6b-...", "b4abdf4d-...", "d754822f-..." |
| api_version | string | false | 100000 | 100.00% | 0.00% | "1.0" |
| store_id | string | false | 100000 | 100.00% | 0.00% | "41", "62", "10", "7", "50" |
| local_time | string | false | 100000 | 100.00% | 0.00% | "2020-05-22 ...", "2020-05-19 ...", "2020-05-27 ..." |
| show_recommendation | null,string | false | 100000 | 100.00% | 18.72% | "true", "false", "true; NEXTSMARTY_DEVICE_ID=..." |
| current_url | string | false | 100000 | 100.00% | 0.00% | "https://www.glamira.com/...", "https://www.glamira.com.mx/...", ... |
| referrer_url | string | false | 100000 | 100.00% | 0.00% | "https://www.google.com/", "https://www.glamira.com.mx/...", ... |
| email_address | string | false | 100000 | 100.00% | 0.00% | "", "simu.gasser@gmail.com", "afarhadi1372@gmail.com" |
| collection | string | false | 100000 | 100.00% | 0.00% | "view_landing_page", "select_product_option", ... |
| product_id | string | false | 53826 | 53.83% | 0.00% | "99564", "95758", "103470", ... |
| option | array,object | false | 82925 | 82.93% | 0.00% | "[object]", 1, 2 |
| option[] | object | true | 81312 | 81.31% | 0.00% | "[object]" |
| option[].option_label | string | true | 81043 | 81.04% | 0.00% | "diamond", "alloy", "stone/diamonds" |
| option[].option_id | string | true | 80585 | 80.59% | 0.00% | "196784", "149165" |
| option[].value_label | string | true | 81043 | 81.04% | 0.00% | "blackdiamond", "", "diamond-Brillant" |
| option[].value_id | string | true | 80852 | 80.85% | 0.00% | "1575088", "1124036" |
| recommendation | boolean | false | 26527 | 26.53% | 0.00% | false |
| utm_source | boolean,string | false | 26527 | 26.53% | 0.00% | false, "criteo", "instagram" |
| utm_medium | boolean,string | false | 26527 | 26.53% | 0.00% | false, "retargeting", "sorting" |
| viewing_product_id | string | false | 4873 | 4.87% | 0.00% | "102774", "95559" |
| price | null,string | false | 478 | 0.48% | 0.84% | "316.00", "915,00", "22 688,00" |
| currency | null,string | false | 478 | 0.48% | 0.84% | "£", "€", "kr", "$" |
| is_paypal | boolean,null | false | 478 | 0.48% | 99.16% | true |
| key_search | null,string | false | 541 | 0.54% | 68.21% | "algra", "AAAA", ... |
| recommendation_product_id | null,string | false | 577 | 0.58% | 9.53% | "89406", "110629" |
| recommendation_product_position | number,string | false | 90 | 0.09% | 0.00% | "", 5, 6 |
| recommendation_clicked_position | null,number | false | 487 | 0.49% | 11.29% | 0 |
| order_id | number,string | false | 262 | 0.26% | 0.00% | "", 910066953, 620291469 |
| cart_products | array | false | 1040 | 1.04% | 0.00% | 1, 5, 0 |
| cart_products[] | object | true | 1876 | 1.88% | 0.00% | "[object]" |
| cart_products[].product_id | number | true | 1876 | 1.88% | 0.00% | 91018, 92470 |
| cart_products[].amount | number | true | 362 | 0.36% | 0.00% | 1,4 |
| cart_products[].option | array,string | true | 1876 | 1.88% | 0.00% | 2, "" |
| cart_products[].option[] | object | true | 2548 | 2.55% | 0.00% | "[object]" |
| cart_products[].option[].value_label | string | true | 2548 | 2.55% | 0.00% | "White Sapphire", "Weißgold 585" |
| option.stone | string | false | 91 | 0.09% | 0.00% | "12", "6" |
| option.pearlcolor | string | false | 91 | 0.09% | 0.00% | "black_pearl" |
| option.finish | string | false | 91 | 0.09% | 0.00% | "polished", "sandy" |

## Sample Document

```json
{
  "_id": "5ed8cb2bc671fc36b74653ad",
  "time_stamp": 1591266092,
  "ip": "37.170.17.183",
  "user_agent": "Mozilla/5.0 (iPhone...)",
  "resolution": "375x667",
  "user_id_db": "502567",
  "device_id": "beb2cacb-...",
  "api_version": "1.0",
  "store_id": "12",
  "local_time": "2020-06-04 12:21:27",
  "show_recommendation": "false",
  "current_url": "https://www.glamira.fr/glamira-pendant-viktor.html?alloy=yellow-375",
  "referrer_url": "https://www.glamira.fr/men-s-necklaces/",
  "email_address": "pereira.vivien@yahoo.fr",
  "recommendation": false,
  "utm_source": false,
  "utm_medium": false,
  "collection": "view_product_detail",
  "product_id": "110474",
  "option": [
    {
      "option_label": "alloy",
      "option_id": "332084",
      "value_label": "",
      "value_id": "3279318"
    },
    {
      "option_label": "diamond",
      "option_id": "",
      "value_label": "",
      "value_id": ""
    }
  ]
}
```
