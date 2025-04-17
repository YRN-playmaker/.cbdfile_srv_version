--注定一抽
function c100032.initial_effect(c)

 --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PREDRAW+EVENT_PHASE_START)
	e1:SetTarget(c100032.target)
	e1:SetCondition(c100032.condition)
	e1:SetOperation(c100032.activate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_SKIP_DP)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,100032+EFFECT_COUNT_CODE_OATH)
	e2:SetReset(RESET_PHASE+PHASE_END,5)
	Duel.RegisterEffect(e2,tp)
end
function c100032.filter(c)
	return (c:IsType(TYPE_MONSTER) or c: IsType(TYPE_SPELL) or c: IsType(TYPE_TRAP)  ) and  c:IsAbleToHand()
end
function c100032.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=4000
end
function c100032.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100032.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c100032.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100032.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

