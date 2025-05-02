function capitalize(str)
  return string.gsub(" " .. str, "%W%l", string.upper):sub(2)
end
