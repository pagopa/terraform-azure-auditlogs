WITH filteredRecords AS(
  SELECT udf.filteredRecords(records) as array
  FROM [${input_name}]
)

SELECT array
INTO  [${output_name}]
FROM filteredRecords
