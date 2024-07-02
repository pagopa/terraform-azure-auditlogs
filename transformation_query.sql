WITH records AS(
  SELECT records.arrayvalue as sig
  FROM [${input_name}]
  CROSS APPLY GetArrayElements(records) AS records
)

SELECT sig.*
INTO [${output_name}]
FROM records
WHERE sig.Properties.audit='true'
