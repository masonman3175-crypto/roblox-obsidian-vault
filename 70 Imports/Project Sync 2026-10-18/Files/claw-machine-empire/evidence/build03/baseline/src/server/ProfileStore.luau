-- Injected backend: UpdateAsync(key, transform). All calls per session are serialized.
local Economy=require(game.ReplicatedStorage.ClawEmpire.Shared.Economy)
local Store={}
Store.__index=Store
local function copy(t)
    if type(t)~="table" then return t end
    local out={}; for k,v in pairs(t) do out[k]=copy(v) end; return out
end
Store.copy=copy
function Store.new(backend,clock)
    return setmetatable({backend=backend,clock=clock or os.time,lease=180},Store)
end
function Store:load(key,token)
    local now=self.clock()
    local ok,record=pcall(function()
        return self.backend:UpdateAsync(key,function(old)
            if old~=nil and (type(old)~="table" or not Economy.validate(old.data)) then return nil end
            if old and old.lock and (type(old.lock)~="table" or type(old.lock.expires)~="number"
                or (old.lock.expires>now and old.lock.id~=token)) then return nil end
            return {data=if old then old.data else Economy.new(),lock={id=token,expires=now+self.lease}}
        end)
    end)
    if not ok then return nil,"Data service unavailable. Your saved arcade was not replaced." end
    if not record or not record.lock or record.lock.id~=token then return nil,"Profile busy or needs recovery. Please rejoin shortly." end
    return {key=key,token=token,data=copy(record.data),expires=record.lock.expires,saving=false,closed=false}
end
function Store:save(session,release)
    if session.closed or session.saving then return false,"busy" end
    session.saving=true
    local now=self.clock(); local snapshot=copy(session.data)
    if not Economy.validate(snapshot) then session.saving=false; return false,"invalid profile" end
    local ok,record=pcall(function()
        return self.backend:UpdateAsync(session.key,function(old)
            if not old or not old.lock or old.lock.id~=session.token or old.lock.expires<=now then return nil end
            return {data=snapshot,lock=if release then nil else {id=session.token,expires=now+self.lease}}
        end)
    end)
    session.saving=false
    -- UpdateAsync returns nil when a callback cancels. Never treat that as a save.
    if not ok or not record or (not release and (not record.lock or record.lock.id~=session.token)) then return false,"save failed or session ownership lost" end
    session.expires=now+self.lease; session.closed=release==true
    return true
end
return Store
