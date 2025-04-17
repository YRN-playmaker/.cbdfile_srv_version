-- 效果怪兽卡 c100031
function c100031.initial_effect(c)
	-- ①：丢弃1张魔法卡，从卡组特殊召唤1只【迪士尼】怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,100031)
	e1:SetCost(c100031.spcost)
	e1:SetTarget(c100031.sptg)
	e1:SetOperation(c100031.spop)
	c:RegisterEffect(e1)

	-- ②：当自己场上有其他「键刃使」怪兽通常召唤成功时，抽1张卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100031,0)) -- ②效果文本提示
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,100031+1)
	e2:SetCondition(c100031.drcon)
	e2:SetTarget(c100031.drtg)
	e2:SetOperation(c100031.drop)
	c:RegisterEffect(e2)

	-- ③：当场上有「键刃使 利库」存在时，这张卡可以变为5星
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100031,1)) -- ③效果文本提示
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,100031+2)
	e3:SetCondition(c100031.lvcon)
	e3:SetTarget(c100031.lvtg)
	e3:SetOperation(c100031.lvop)
	c:RegisterEffect(e3)
end

-- ①：丢弃1张魔法卡作为代价
function c100031.spellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end

function c100031.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100031.spellfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c100031.spellfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end

function c100031.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100031.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function c100031.spfilter(c,e,tp)
	return c:IsSetCard(0x209) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100031.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100031.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ②：当自己场上有其他「键刃使」怪兽通常召唤成功时，抽1张卡
function c100031.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c100031.kbfilter,1,nil,tp) and eg:GetFirst():GetCode()~=100031
end

function c100031.kbfilter(c,tp)
	return c:IsSetCard(0x209) and c:IsControler(tp)
end

function c100031.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function c100031.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

-- ③：等级变化的条件与效果
function c100031.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c100031.rikufilter,tp,LOCATION_MZONE,0,1,nil)
end

function c100031.rikufilter(c)
	return c:IsCode(100014) and c:IsFaceup()
end

function c100031.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function c100031.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end


