-- Pure co-op queue kernel. No Player instances, remotes or world mutations.
local Q={}
Q.__index=Q
function Q.new(modes,countdown)
    local self=setmetatable({Queues={},Membership={},Countdown=countdown},Q)
    for _,m in modes do self.Queues[m.Id]={Size=m.Size,Members={},Deadline=nil,Generation=0} end
    return self
end
function Q:Remove(id)
    local mode=self.Membership[id]
    if not mode then return false end
    local q=self.Queues[mode]
    for i,v in q.Members do if v==id then table.remove(q.Members,i);break end end
    q.Deadline=nil;q.Generation+=1
    self.Membership[id]=nil
    return true
end
function Q:Add(id,mode)
    local q=self.Queues[mode]
    if not q then return false,"Unknown queue" end
    if self.Membership[id]==mode then return true end
    if #q.Members>=q.Size then return false,"Queue full" end
    self:Remove(id)
    table.insert(q.Members,id);self.Membership[id]=mode;q.Deadline=nil;q.Generation+=1
    return true
end
function Q:Step(now,eligible)
    local launches={}
    for mode,q in self.Queues do
        local remove={}
        for _,id in q.Members do if not eligible(id,mode) then table.insert(remove,id) end end
        for _,id in remove do self:Remove(id) end
        if #q.Members==q.Size then
            if not q.Deadline then q.Deadline=now+self.Countdown end
            if now>=q.Deadline then
                local members=table.clone(q.Members)
                for _,id in members do self.Membership[id]=nil end
                q.Members={};q.Deadline=nil;q.Generation+=1
                table.insert(launches,{Mode=mode,Members=members})
            end
        else q.Deadline=nil end
    end
    return launches
end
function Q:Snapshot()
    local result={}
    for mode,q in self.Queues do result[mode]={Count=#q.Members,Size=q.Size,Deadline=q.Deadline} end
    return result
end
return Q
