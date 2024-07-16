function filteredRecords(records) {
  return records.filter(record => record.Properties.audit == "true")
}
