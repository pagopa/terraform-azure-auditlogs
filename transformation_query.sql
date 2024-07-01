WITH records AS(
  SELECT records.arrayvalue as sig
  FROM [eventhub-stream-input]
  CROSS APPLY GetArrayElements(records) AS records
)

SELECT sig.*
INTO [adltitnexportlaw-container-output]
FROM records
WHERE sig.Properties.audit='true'
