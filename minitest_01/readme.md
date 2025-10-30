Given a table with the following structure:

```sql
CREATE TABLE T_CONFIG_RLS (
    UserID VARCHAR(30),
    TableName VARCHAR(50),
    FieldName VARCHAR(50),
    Value VARCHAR(255)
);
```

| **UserID** | **TableName** | **FieldName** | Value |
| --- | --- | --- | --- |
| U03 | PurchaseOrder | VendorId | VS04,UK8A |
| U03 | PurchaseOrder | PlantID | W1,W4 |
| U03 | PurchaseOrder | DeliveryMethodName | %sea%,air% |
| U03 | ProductCategory | CategoryName | OLED |
| U31 | * | * | * |
| U05 | PurchaseOrder | * | * |
| U09 | Customer | PostalCityID | 1,6,7,3 |
| U09 | Customer | CustomerCategoryName | %Suspects%, Loyal%, %Referral  |
| U09 | Customer | DeliveryCityID | * |
| U15 | Invoice | CustomerCategoryName | %boxes |
| UE1 | SaleOrder | CustomerID | %123 |
| UE1 | SaleOrderDetail | ProductID | 143,F35 |
| ADV | * | DeliveryMethodName | Road%, %Rail |
| ADV | * | VendorId | VP19,UB55 |

Write a SQL function to generate conditions in the WHERE clause of a query when a specific user retrieves data from a table.

- Input: TableName, UserID
- Output: a string containing the condition for the WHERE clause.
- Example:
    - **`UserID`:** UE1 and **`TableName`:** SaleOrder —> "Customer LIKE '%123%'"
    - **`UserID`:** UE1 and **`TableName`:** SaleOrderDetail—> "ProductID IN ('143','f35')"
- Users marked with a star (*) can read all values —> return "1=1"
- If **`TableName`**=’*’ —> return ‘1=1’ for this **`UserID`**in all case
- If `FieldName` =’*’ or `Value`=’*’ > Return ‘1=1’ for this **`UserID`** when apply table in **`TableName`**
- For cases where the condition does not match, return ‘1=0’.
- **Advanced Requirements:**
    
     For `UserID` "ADV", the system must inspect every table in the schema to determine if a specific field exists. If the field is present, it should generate appropriate SQL conditions based on the field’s values. If absent, the system should return **`1=0.`**
    
    ```sql
    CREATE TABLE Product (
        ProductID VARCHAR(30) PRIMARY KEY,
        ProductName VARCHAR2(255),
        Price DECIMAL(10, 2)
    );
    
    -------------------------------------------------
    CREATE TABLE Vendor (
        VendorID VARCHAR(10) PRIMARY KEY,
        VendorName VARCHAR2(255),
        Address VARCHAR2(500)
    );
    ---------------------------
    CREATE TABLE DeliveryMethod (
        DeliveryMethodID VARCHAR(10) PRIMARY KEY,
        DeliveryMethodName VARCHAR2(255)
    );
    
    ```
    
    Expected Output:
    
    - **`UserID`:** ADV and **`TableName`:** DeliveryMethod —> "DeliveryMethodName LIKE 'Road%' OR DeliveryMethodName LIKE '%Rail' "
    - **`UserID`:** ADV and **`TableName`:** Vendor—> "VendorID  in ( ‘VP19’,’UB55’)"
    - **`UserID`:** ADV and **`TableName`:** Product—> 1=0
