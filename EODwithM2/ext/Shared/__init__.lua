
Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances
	for _, instance in ipairs(instances) do
		if instance.instanceGuid == Guid("3BB40312-FCB9-47CA-B92E-3FE29BDF4B77") then
			instance = PartComponentData(instance)
			instance:MakeWritable()
			instance.excluded = false
		end
	end
end)
