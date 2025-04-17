-- 超量怪兽 (c100048)
function c100048.initial_effect(c)
	-- 4星怪兽x3
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()

	-- 这张卡的属性也当作「暗」使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e0)

	-- 对方发动魔法·陷阱·效果怪兽时
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100048,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c100048.negcon)
	e1:SetCost(c100048.negcost)
	e1:SetOperation(c100048.negop)
	c:RegisterEffect(e1)

	-- 没有超量素材的这张卡不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c100048.atkcon)
	c:RegisterEffect(e2)

	-- 回合结束阶段回到卡组
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100048,1))
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c100048.retcon)
	e3:SetTarget(c100048.rettg)
	e3:SetOperation(c100048.retop)
	c:RegisterEffect(e3)
end

-- 对方发动魔法·陷阱·效果怪兽时的条件
function c100048.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and (re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP) or re:IsType(TYPE_MONSTER))
		and Duel.IsChainNegatable(ev)
end

-- 去除超量素材的成本
function c100048.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- 无效并破坏效果
function c100048.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
	-- 这张卡攻击上升200
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end

-- 没有超量素材的这张卡不能攻击的条件
function c100048.atkcon(e)
	return e:GetHandler():GetOverlayCount()==0
end

-- 回合结束阶段回到卡组的条件
function c100048.retcon(e)
	return e:GetHandler():GetOverlayCount()==0
end

-- 目标
function c100048.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end

-- 回到额外卡组
function c100048.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
end
