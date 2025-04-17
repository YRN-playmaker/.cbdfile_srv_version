-- 键刃使 凯莉 Final Form
function c100023.initial_effect(c)
	-- Fusion summon requirements: 键刃使 凯莉 + [键刃使]怪兽
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,100009,aux.FilterBoolFunction(Card.IsSetCard,0x208),1,true,true)

	-- This card cannot be Special Summoned except by Fusion Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	

	-- ②: Once per turn (quick effect): Send this card to the graveyard to Fusion Summon using materials from field, graveyard, or banished zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100023,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,100023)
	e2:SetCost(c100023.fusioncost)
	e2:SetTarget(c100023.fusiontg)
	e2:SetOperation(c100023.fusionop)
	c:RegisterEffect(e2)
end


-- ②: Cost - Send this card to the graveyard
function c100023.fusioncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- ②: Fusion Summon target function (gather materials from field, graveyard, and banished zone)
function c100023.fusionfilter(c,e)
	return (c:IsOnField() or c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)) and not c:IsImmuneToEffect(e)
end

function c100023.spfilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) 
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
		and c:CheckFusionMaterial(m,gc,chkf) and not c:IsCode(c100023)
end

-- ②: Fusion Summon target
function c100023.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(c100023.fusionfilter,nil,e)
		mg1:Merge(Duel.GetMatchingGroup(c100023.fusionfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e))
		local res=Duel.IsExistingMatchingCard(c100023.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,e:GetHandler(),chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c100023.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,e:GetHandler(),chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- ②: Fusion Summon operation
function c100023.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c100023.fusionfilter,nil,e)
	mg1:Merge(Duel.GetMatchingGroup(c100023.fusionfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e))
	local sg1=Duel.GetMatchingGroup(c100023.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,e:GetHandler(),chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c100023.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,e:GetHandler(),chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,e:GetHandler(),chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end


