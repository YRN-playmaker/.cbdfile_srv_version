function c100066.initial_effect(c)
	--Activate and place 1 counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c100066.activate)
	c:RegisterEffect(e1)
	
	--Place 1 counter during the Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c100066.counterop)
	c:RegisterEffect(e2)
	
	--Add "指令" card to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100066,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,100066)
	e3:SetTarget(c100066.thtg)
	e3:SetOperation(c100066.thop)
	c:RegisterEffect(e3)
	
	--Remove counters to add "指令" cards from GY to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100066,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,100066+1)
	e4:SetCost(c100066.rmcost)
	e4:SetTarget(c100066.rmtg)
	e4:SetOperation(c100066.rmop)
	c:RegisterEffect(e4)
end

-- Effect ①: Activate and place 1 counter
function c100066.activate(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x3d1,1)
end

-- Effect ②: Place 1 counter during the Standby Phase
function c100066.counterop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x3d1,1)
end

-- Effect ③: Add "指令" card to hand
function c100066.thfilter(c)
	return c:IsSetCard(0x3d1) and c:IsAbleToHand()
end
function c100066.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100066.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c100066.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100066.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Effect ④: Remove counters to add "指令" cards from GY to hand
function c100066.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x3d1)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x3d1,1,REASON_COST) and ct>0 end
	local maxct=math.min(e:GetHandler():GetCounter(0x3d1),ct)
	local ct=Duel.AnnounceNumber(tp,1,maxct)
	e:SetLabel(ct)
	e:GetHandler():RemoveCounter(tp,0x3d1,ct,REASON_COST)
end
function c100066.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100066.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c100066.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.SelectMatchingCard(tp,c100066.thfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
