local ref = {};
ref.__index = ref;

-- Methods always return their refs, meaning methods can be chained.

-- Creates a new `ref` with `InitialValue?`
function ref:Create(InitialValue: any?)
	local self = setmetatable({}, ref);
	
	self._init = InitialValue;
	self._binds = {};
	self._order = {};
	
	return self;
end;

-- Add a binding to the ref. Bindings always run in the order they were bound.
-- You can bind a ref at a specific spot by supplying an `At`.
-- Refs that already have the name passed will be rebound at the position they were at before.
-- If at is 'last' then At will be set to math.huge.
function ref:Bind(Name: string, BindFunction: (any?) -> (any?), At: (number | 'last')?)
	if (table.find(self._order, Name)) then
		At = table.find(self._order, Name);
		self:Unbind(Name);
	end;
	
	if (not At) then
		At = #self._order + 1;
	elseif (At == 'last') then
		At = math.huge;
	end;
	
	table.insert(self._order, At, Name);
	self._binds[Name] = BindFunction;
	
	return self;
end;

-- Unbind a binding from the ref.
function ref:Unbind(Name: string)
	if (not table.find(self._order, Name)) then
		warn(Name..' does not exist in ref.');
		return self;
	end;
	
	-- Remove Name from _order
	table.remove(self._order, table.find(self._order, Name));
	self._binds[Name] = nil;
	
	return self;
end;

-- Get the value from the ref.
function ref:Get()
	local Value = self._init;
	
	-- Binds are added to the order table so they run in order.
	for i,v in pairs(self._order) do
		-- The bind doesnt exist, skip
		if (not self._binds[v]) then
			continue;
		end;
		-- Run the bind and set value to bind.
		Value = self._binds[v](Value);
	end;
	
	return Value;
end;

-- Sets the initial value.
function ref:Set(Value: any?)
	self._init = Value;
	return self;
end;

-- Destroys the ref. Does not return self.
function ref:Destroy()
	table.clear(self);
	self = nil;
end;

return ref;
