-- 超量怪兽卡 c100044
function c100044.initial_effect(c)
	-- 超量召唤条件
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x208),5,2)
	c:EnableReviveLimit()

	-- ①：去除1个超量素材，将对方额外卡组最上方的1张卡里侧表示除外
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100044,0)) -- 效果文本提示
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c100044.rmcost)
	e1:SetTarget(c100044.rmtarget)
	e1:SetOperation(c100044.rmoperation)
	c:RegisterEffect(e1)

	-- ②：魔法·陷阱·怪兽的效果发动时，将这张卡送去墓地使发动无效并破坏，并特殊召唤1只【键刃使 索拉】
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100044,1)) -- 效果文本提示
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,100044)
	e2:SetCondition(c100044.negcon)
	e2:SetCost(c100044.negcost)
	e2:SetTarget(c100044.negtarget)
	e2:SetOperation(c100044.negoperation)
	c:RegisterEffect(e2)
end

-- ①：去除1个超量素材
function c100044.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ①：将对方额外卡组最上方的1张卡里侧表示除外
function c100044.rmtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_EXTRA,0)>0 end
end

function c100044.rmoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:RandomSelect(tp,1)
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		Duel.ShuffleExtra(1-tp) -- 在除外之后洗切对方的额外卡组
	end
end


-- ②：魔法·陷阱·怪兽的效果发动时，将这张卡送去墓地使发动无效并破坏
function c100044.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

function c100044.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function c100044.negtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp) 
		and Duel.IsExistingMatchingCard(c100044.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

function c100044.spfilter(c,e,tp)
	return c:IsCode(100000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100044.negoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.Destroy(eg,REASON_EFFECT) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,c100044.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

