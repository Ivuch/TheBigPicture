SELECT  MS.SNCODE {s.id}, 
							 MS.DES {s.servicio}, 
							 TMB.ACCESSFEE {s.tarifa}, 
							decode(CS_OVW_ACC_PRD, null, 0, CS_OVW_ACC_PRD) {s.periodosPendientes},
							 to_number(decode(CS_OVW_ACC_PRD,null,null,decode(least(nvl(CS_OVW_ACC_PRD,-3),1) 
							 	,1,decode(CS_OVW_ACCESS,'R',cs.cs_access*TMB.accessfee, cs.cs_access), -1,
							 	 decode(CS_OVW_ACCESS,'R',cs.cs_access*TMB.accessfee, cs.cs_access), TMB.ACCESSFEE)))
							 	  {s.ajuste} FROM CONTR_SERVICES CS, DIRECTORY_NUMBER DN, MPULKTMB TMB, MPUSNTAB MS 
							 WHERE CS.CO_ID = :pCoId AND CS.DN_ID = DN.DN_ID() 
							 AND TMB.ACCESSFEE > 0
							 AND CS.TMCODE = TMB.TMCODE 
							 AND CS.SPCODE = TMB.SPCODE 
							 AND CS.SNCODE = MS.SNCODE 
							 AND substr(CS_STAT_CHNG,-1) in ('a','s') 
							 AND CS.SNCODE = TMB.SNCODE 
							 AND MS.DES LIKE 'GARANT%' 
							 AND TMB.STATUS = 'P' 
							 AND TMB.VSCODE = 1 
							 AND CS.CS_SEQNO = (SELECT MAX(C.CS_SEQNO) FROM CONTR_SERVICES C WHERE C.CO_ID = :pCoId) 
							 ORDER BY CS.SNCODE