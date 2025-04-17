--键刃使 索拉Wisdom Form
function c100019.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x208),2,2)

	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetDescription(aux.Stringid(100019,0))
	e1:SetCondition(c100019.spcon)
	e1:SetOperation(c100019.spop)
	c:RegisterEffect(e1)

	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100019,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,100019)
	e2:SetCondition(c100019.negcon)
	e2:SetCost(c100019.negcost)
	e2:SetTarget(c100019.negtg)
	e2:SetOperation(c100019.negop)
	c:RegisterEffect(e2)
end

--special summon
function c100019.spfilter(c,tp)
	return c:IsSetCard(0x208) and c:IsLevel(8) and c:IsControler(tp)
end
function c100019.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,c100019.spfilter,1,nil,tp)
end
function c100019.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,c100019.spfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end

--negate
function c100019.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and Duel.IsChainNegatable(ev)
end
function c100019.cfilter(c,type)
	return c:GetType()&type~=0 and c:IsDiscardable()
end
function c100019.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local type=re:GetHandler():GetType()
	if chk==0 then return Duel.IsExistingMatchingCard(c100019.cfilter,tp,LOCATION_HAND,0,1,nil,type) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c100019.cfilter,tp,LOCATION_HAND,0,1,1,nil,type)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function c100019.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c100019.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c100019.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		if Duel.IsExistingMatchingCard(c100019.thfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(100019,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,c100019.thfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end

-----
