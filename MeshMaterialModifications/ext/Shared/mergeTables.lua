function mergeTables(a, b)
  local merged = {}

  for k, v in pairs(a) do
    merged[k] = v
  end

  for k, v in pairs(b) do
    merged[k] = v
  end

  return merged
end