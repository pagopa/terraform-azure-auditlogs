.create external table ['AuditLogs'] (['AppRoleInstance']:string,['AppRoleName']:string,['AppVersion']:string,['ClientCity']:string,['ClientCountryOrRegion']:string,['ClientIP']:string,['ClientOS']:string,['ClientStateOrProvince']:string,['ClientType']:string,['IKey']:guid,['ItemCount']:int,['Name']:string,['OperationId']:guid,['ParentId']:string,['Properties']:dynamic,['ResourceGUID']:guid,['SDKVersion']:string,['SourceSystem']:string,['TenantId']:guid,['TimeGenerated']:datetime,['Type']:string,['_BilledSize']:int,['_ItemId']:guid,['_Internal_WorkspaceResourceId']:string,['_ResourceId']:string)
    kind = blob
partition by (['IngestionDatetime']:datetime )
pathformat = (datetime_pattern("yyyy/MM/dd/HH/mm", ['IngestionDatetime']))
    dataformat = multijson
    (
        h@'https://${storage_account_name}.blob.core.windows.net/${storage_account_container_name}/record;impersonate'
    )
    with (FileExtension=json)