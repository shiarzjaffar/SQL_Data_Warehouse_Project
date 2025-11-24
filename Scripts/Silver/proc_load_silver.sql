/* 
===============================================================================
Procedure: silver.load_silver
Layer:     SILVER (Transformed & Cleansed Data Layer)

Purpose:
    This stored procedure loads the SILVER layer by extracting data from the 
    BRONZE layer, applying standardization, validation, cleansing, and basic 
    business-rule transformations. Each table is truncated and fully reloaded 
    to maintain data consistency.

Source → Target Tables:
    bronze.crm_cust_info      → silver.crm_cust_info
    bronze.prd_info_CSV       → silver.crm_prd_info
    bronze.sales_details      → silver.crm_sales_details
    bronze.CUST_AZ12          → silver.erp_cust_az12
    bronze.LOC_A101           → silver.erp_loc_a101
    bronze.PX_CAT_G1V2        → silver.erp_px_cat_g1v2

Key Transformations:
    • Trimming string fields (names, codes)
    • Mapping short codes to descriptive labels (gender, marital status, product lines)
    • Standardizing date fields, discarding invalid dates
    • Recomputing sales amounts when mismatched with price × quantity
    • Deriving product end dates using LEAD() (effective-dating logic)
    • Normalizing customer IDs (removing prefixes/dashes)
    • Mapping country codes to readable names
    • Replacing NULL/invalid numeric values with safe defaults

Performance Monitoring:
    • Execution time measured for each table load
    • Total batch duration measured

Error Handling:
    • TRY/CATCH block captures all load failures
    • Outputs:
        - error message
        - SQL error state

Usage:
    EXEC silver.load_silver;

Notes:
    - Designed for batch processing in a Data Warehouse (ELT pipeline)
    - Assumes Bronze layer tables are already populated and validated at ingestion time
===============================================================================
*/



create or alter procedure silver.load_silver as
begin

	declare @start_time datetime,
			@end_time datetime,
			@batch_start_time datetime,
			@batch_end_time datetime;
	begin try
	set @batch_start_time = getdate();
	print'==============================================';
	print'loading silver layer'
	print'==============================================';

	print'----------------------------------------------';
	print'loading CRM layer'
	print'----------------------------------------------';

	set @start_time = GETDATE();
	print '>> Truncate Table :silver.crm_cust_info' 
	truncate table silver.crm_cust_info;
	print '>> Insert data into :silver.crm_cust_info' 
	--silver.crm_cust_info
	insert into silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_gndr,
	cst_marital_status,
	cst_create_date
	)

	select
	cst_id, cst_key, 
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
	case when upper(trim(cst_gndr)) = 'M' then 'Male'
			when upper(trim(cst_gndr)) = 'F' then 'Female'
			else 'Unknown'
		END cst_gndr,
	case when upper(trim(cst_marital_status)) = 'M' then 'Married'
			when upper(trim(cst_marital_status)) = 'S' then 'Single'
			else 'Unknown'
		END marital_status,
	cst_create_date
	from bronze.crm_cust_info

	set @end_time = getdate();
	print '>> Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '>>-------------------'

	set @start_time = GETDATE();
	print '>> Truncate Table :silver.crm_prd_info' 
	truncate table silver.crm_prd_info;
	print '>> Insert data into :silver.crm_prd_info'
	
	

	--silver.crm_prd_info
	insert into silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)

	select 
	PRD_id as prd_id,
	replace(SUBSTRING(PRD_key,1,5), '-', '_')as cat_id,
	SUBSTRING(PRD_key,7,LEN(PRD_key))as prd_key,
	PRD_NM as prd_nm,
	isnull(PRD_COST,0) as prd_cost,
	case upper(trim(PRD_LINE))
		when 'M' then 'Mountain'
		when 'R' then 'Road'
		when 'S' then 'Other Sales'
		when 'T' then 'Touring'
		else 'n/a' END as prd_line,
	cast( PRD_START_dt as date) as prd_start_dt,
	dateadd( day, -1,cast( lead (PRD_START_dt) over (partition by prd_key order by PRD_START_dt) as date))as prd_end_dt
	from bronze.prd_info_CSV

	set @end_time = getdate();
	print '>> Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '>>-------------------'

	set @start_time = GETDATE();
	print '>> Truncate Table :silver.crm_sales_details' 
	truncate table silver.crm_sales_details;
	print '>> Insert data into :silver.crm_sales_details' 

	--silver.crm_sales_details
	insert into silver.crm_sales_details(
		sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)

	select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when len(sls_order_dt) != 8 or sls_order_dt <= 0 then null
	else cast(cast(sls_order_dt as nvarchar)as date)  end as sls_order_dt,

	case when len(sls_ship_dt) != 8 or sls_ship_dt <= 0 then null
	else cast(cast(sls_ship_dt as nvarchar)as date)  end as sls_ship_dt,

	case when len(sls_due_dt) != 8 or sls_due_dt <= 0 then null
	else cast(cast(sls_due_dt as nvarchar)as date)  end as sls_due_dt,

	case when sls_sales is null or sls_sales <=0 or sls_sales != abs(sls_price) * sls_quantity
	then sls_quantity * abs(sls_price) 
	else sls_sales 
	end as sls_sales,

	sls_quantity,

	case when sls_price is null or  sls_price <= 0 
	then  abs(sls_sales) / nullif(sls_quantity,0) 
	else sls_price 
	end as sls_price

	from bronze.sales_details

	set @end_time = getdate();
	print '>> Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '>>-------------------'


	set @start_time = GETDATE();
	print '>> Truncate Table :silver.erp_cust_az12' 
	truncate table silver.erp_cust_az12;
	print '>> Insert data into :silver.erp_cust_az12' 

	--silver.erp_cust_az12
	insert into silver.erp_cust_az12(
	cid,
	bdate,
	gen
	)

	select
	case when CID like 'NAS%' then substring(CID, 4,len(CID))
	else CID end as cid,
	case when BDATE >  getdate()  then null else BDATE end as bdate,
	case when trim(gen) in ('F','Female') then 'Female'
		when trim(gen) in ('M', 'Male') then 'Male'
		else 'n/a'
		end as gen
	from bronze.CUST_AZ12

	set @end_time = getdate();
	print '>> Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '>>-------------------'


	set @start_time = GETDATE();
	print '>> Truncate Table :silver.erp_loc_a101' 
	truncate table silver.erp_loc_a101;
	print '>> Insert data into :silver.erp_loc_a101'

	--silver.erp_loc_a101
	insert into silver.erp_loc_a101(
	cid,
	cntry
	)

	select
	replace(CID,'-',''),
	case when TRIM(CNTRY) = 'DE' then 'germany'
		 when trim(CNTRY) in ('US', 'USA') then 'United States'
		 when trim(CNTRY) = '' or trim(CNTRY) is null then 'n/a'
		 else trim(CNTRY) end as CNTRY
	from bronze.LOC_A101

	set @end_time = getdate();
	print '>> Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '>>-------------------'


	set @start_time = GETDATE();
	print '>> Truncate Table :silver.erp_px_cat_g1v2' 
	truncate table silver.erp_px_cat_g1v2;
	print '>> Insert data into :silver.erp_px_cat_g1v2'

	--silver.erp_px_cat_g1v2
	insert into silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
	)

	select 
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	from 
	bronze.PX_CAT_G1V2

	set @end_time = getdate();
	print '>> Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '>>-------------------'

	set @batch_end_time = GETDATE()
	print'================================'
	print'silver layer is completed'
	print ' Total Load Duration: '+cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + 'seconds';

	end try
		begin catch 
		print'=============================================='
		print'error occured during loading bronze layer'
		print'Error message'+ error_message();
		print'Error message'+ cast(error_message() as nvarchar);
		print'Error message'+ cast(error_state() as nvarchar);
		print'=============================================='
	end catch

end
