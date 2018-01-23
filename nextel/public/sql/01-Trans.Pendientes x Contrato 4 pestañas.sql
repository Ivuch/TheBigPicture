Select ' 0' orden
      ,'/***********************************************************************'||chr(10)||
       '-- ATENCION --'||chr(10)||
       'Este contrato tiene pendiente una gestión de PRECO a '||data.dias||' días, '||decode(data.inv,0,'sin','con')||' movimiento de inventario'||chr(10)||
       '-- DATA --'||chr(10)||
       'Contrato                      : '||data.co_id||chr(10)||
       'Fecha en que debería suspender: '||to_char(data.fecha+data.dias,'dd/mm/yyyy')||' '||Decode(trunc(data.fecha+data.dias),trunc(sysdate)  ,'(hoy a las '||to_char(data.fecha,'hh24:mi:ss')||' hs.)'
                                                                                                                              ,trunc(sysdate+1),'(mañana a las '||to_char(data.fecha,'hh24:mi:ss')||' hs.)'
                                                                                                                              ,trunc(sysdate+2),'(pasado a las '||to_char(data.fecha,'hh24:mi:ss')||' hs.)'
                                                                                                                                               ,'(faltan '||trunc(data.fecha+data.dias-sysdate)||' días)'
                                                                                                   )||chr(10)||
       'Estado transaccion_contarto   : '''||data.estado_trx||''' ('||data.tc_status||')'||chr(10)||
       'Usuario que gestionó          : '||data.usuario||chr(10)||
       'Responsabilidad de inventario : '||data.resp_inv||chr(10)||
       'Nro gestión                   : '||data.gestion||chr(10)||
       'Estado gestión                : '||data.estado||chr(10)||
       'Fecha gestión                 : '||data.creacion||chr(10)||
       '************************************************************************/'||chr(10)||
       (Select Decode((Select 'INC' from dual where sysdate < data.fecha + data.dias and data.estado = 'Ce - Cerrado' and data.tc_status = 2)
                     ,'INC','-- **** ATENCION ***'||chr(10)||
                            '-- La preco está cerrada pero no canceló la trx en el contrato'||chr(10)||
                            '-- ¡¡¡AVISAR A NEXUS/PRECO...!!!'
                      )||chr(10)||
               '-- QUERY --'||chr(10)||
               Decode(susp,0, -- Contrato apartado
                               '-- Para volar la trx pendiente que figura fue marcado NO SUSPENDER con fecha '||to_char(f_no_susp,'dd/mm/yyyy hh24:mi:ss')||' por '||usr_no_susp||chr(10)||
                               'Update nxsadm.transaccion_contrato'||chr(10)||
                               '   Set status = 4'||chr(10)||
                               ' Where id = '||data.id_tc||';'
                            , -- Ok
                               '-- Para volar la trx pendiente'||chr(10)||
                               'Update nxsadm.transaccion_contrato'||chr(10)||
                               '   Set status = 4'||chr(10)||
                               ' Where id = '||data.id_tc||';'||chr(10)||chr(10)||
                               '-- Para marcar el/los contrato/s como suspendidos'||chr(10)||
                               'Update nxsadm.pc_trx_equipo_susp'||chr(10)||
                               '   Set fecha_suspendido = sysdate'||chr(10)||
                               ' Where id               = '||id_preco||chr(10)||
                               '   And fecha_suspendido is null;'
                      )||chr(10)
          From dual
         Where (sysdate > data.fecha + data.dias        -- Trx pasada de fecha
                or data.estado = 'Ce - Cerrado'         -- Gestión cerrada
                or susp = 0                             -- contrato marcado <No Susupender>
                )
        ) ejecutar
--      ,data.*
  From (Select dp.id                   id_preco
              ,dp.id_contrato          co_id
              ,dp.dias_a_susp          dias
              ,dp.mov_inv              inv
              ,dp.fecha_suspendido     f_susp
              ,p.motivo                cat
              ,p.no_remito             rto
              ,p.fecha                 fecha
              ,r.descripcion           resp_inv
              ,i.id_vantive            gestion
              ,i.estado_actual         estado
              ,i.fecha_desde_actual    creacion
              ,upper(substr(ap.email_address,instr(ap.email_address,'.',1,1)+1,instr(ap.email_address,'@',1,1)-instr(ap.email_address,'.',1,1)-1))||', '||substr(ap.email_address,1,instr(ap.email_address,'.',1,1)-1) usuario
              ,st.nombre               estado_trx
              ,tc.status               tc_status
              ,tc.id                   id_tc
              ,dp.suspender            susp
              ,dp.usuario_no_suspender usr_no_susp
              ,dp.fecha_no_suspender   f_no_susp
          From nxsadm.pc_trx_equipo_susp dp
              ,nxsadm.pc_trx_proceso_susp_eq p
              ,nxsadm.pc_vnt_resp_inv r
              ,nxsadm.incidente_nexus i
              ,nxsadm.transaccion t
              ,nxsadm.transaccion_contrato tc
              ,nxsadm.def_status st
              ,nxsadm.representantes ap
         Where ap.login_id(+)     = i.usr_actual
           And st.id              = tc.status
           And tc.id_contrato     = dp.id_contrato
           And tc.id_transaction  = t.id
           And t.id_gestion_nexus = i.id_gestion_nexus
           And i.id_gestion_nexus = p.id_gestion_nexus
           And r.id(+)            = p.resp_inv
           And p.id_gestion_nexus = dp.id_gestion_nexus
        ) data
 Where tc_status != 4
   And co_id in (&Contrato)
Union
Select ' 1' Orden,'UPDATE nxsadm.transaccion_contrato SET STATUS = 4, FINALIZATION_STATUS = 4 WHERE ID_CONTRATO = ' || ID_CONTRATO || ' AND STATUS IN (1,2,5);' EJECUTAR
From nxsadm.transaccion_contrato
where ID_CONTRATO IN (&&Contrato)
and status in (1,2,5)
And id_service != 920
union
Select ' 2' Orden,'UPDATE nxsadm.transaccion SET STATUS = 4, FINALIZATION_STATUS = 4 WHERE ID = ' || ID || ' AND STATUS IN (1,2,5);' EJECUTAR
From nxsadm.transaccion
where ID IN (select id From nxsadm.transaccion_contrato
where ID_CONTRATO IN (&&Contrato))
and status in (1,2,5)
And id_service != 920
union
Select ' 3' Orden,'UPDATE nxsadm.transaccion SET STATUS = 4, FINALIZATION_STATUS = 4 WHERE ID = ' || ID || ' AND STATUS IN (1,2,5);' EJECUTAR
from nxsadm.transaccion
where ID_GESTION_NEXUS in (Select ID_GESTION_NEXUS
                          From nxsadm.vw_soporte_transacciones
                          where ID_CONTRATO  IN (&&Contrato)
                          and NOMBRE_SERVICIO != 'Suspender Equipos Precontención')
AND status IN (1,2,5)
UNION
SELECT ' 4' Orden,'UPDATE nxsadm.incidente_nexus SET ESTADO_ACTUAL = ''eliminada'', FECHA_CIERRE = SYSDATE WHERE ID_GESTION_NEXUS = ' || ID_GESTION_NEXUS || ' And ESTADO_ACTUAL != ''Ce - Cerrado'';' EJECUTAR
FROM nxsadm.incidente_nexus
WHERE id_gestion_nexus in (Select NUMERO_GESTION
                             From nxsadm.ge_operacion
                            Where contrato IN (&&Contrato))
And ESTADO_ACTUAL not in ('Ce - Cerrado','eliminada')
UNION
SELECT ' 9' Orden,'-- COMMIT;' FROM DUAL
UNION
    SELECT NULL CORRER, '-- MDSRRTAB' DONDE
--    Select * from MDSRRTAB@AVALON.world
    FROM MDSRRTAB@AVALON.world
    WHERE CO_ID in (0&&Contrato) AND STATUS not in (7,9)
UNION
    SELECT NULL CORRER, '-- MDSOQTAB' DONDE
      FROM MDSOQTAB@AVALON.WORLD MQ, MDSRRTAB@AVALON.WORLD MR
    WHERE MR.REQUEST = MQ.REQUEST AND MR.CO_ID in (0&&Contrato)
        AND MQ.STATUS <> 8
UNION
    SELECT NULL CORRER, '-- MRH' DONDE
      FROM MRH_STATCHG_CONTR@AVALON.WORLD
    WHERE CO_ID in(0&&Contrato) AND STATUS <> 8
UNION
    SELECT NULL CORRER, '-- CONTRACT_HISTORY' DONDE
      FROM CONTRACT_HISTORY@AVALON.WORLD
    WHERE CO_ID in(0&&Contrato) AND CH_PENDING = 'X'
UNION
    SELECT 'UPDATE CONTRACT_ALL@AVALON.WORLD SET 
            IXCODE = PENDING_IXCODE, 
            PENDING_IXCODE = NULL, 
            CO_INPREPAY = CO_INPREPAY_PENDING, 
            CO_INPREPAY_PENDING= NULL 
            WHERE CO_ID = ' || co_id || ';' CORRER, '-- CONTRACT_ALL' DONDE
      FROM CONTRACT_ALL@AVALON.WORLD
    WHERE CO_ID in (0&&Contrato)
    AND (  PENDING_IXCODE IS NOT NULL or CO_INPREPAY_PENDING IS NOT NULL)
UNION
    SELECT 'UPDATE CONTR_SERVICES@AVALON.WORLD SET
            CS_PENDING_STATE = NULL
            WHERE CO_ID = ' || co_id || ';' CORRER, '-- CONTRACT_SERVICES' DONDE
      FROM CONTR_SERVICES@AVALON.WORLD
    WHERE CO_ID in (0&&Contrato)
    AND (CS_PENDING_STATE IS NOT NULL
         OR CS_PENDING_PARAM IS NOT NULL)
UNION
    SELECT NULL CORRER, '-- CONTRACT_CUG_MEMBERSHIP' DONDE
      FROM CONTRACT_CUG_MEMBERSHIP@AVALON.WORLD
    WHERE CO_ID in (0&&Contrato)
    AND PEND_STATUS IS NOT NULL;

SELECT * 
FROM nxsadm.vw_soporte_transacciones
WHERE id_contrato IN (&&Contrato);



SELECT NC.*, NT.status_tx_contrato, NT.status_fin_tx_contrato, 'update nxsadm.transaccion_contrato   set STATUS = 1,  FINALIZATION_STATUS = 0 where ID = '||NC.id||';'  "PARA DEJAR PENDIENTE"
  FROM nxsadm.vw_soporte_transacciones NT,  nxsadm.transaccion_contrato nc
      WHERE   NC.id = NT.id_tx_contrato
      AND    NT.id_contrato IN  (&&Contrato);                             
 /********************************************************* hansed asociado a otra sim **************************************************************************/                             

Select er.id
      ,er.numero_gestion id_nxs
      ,er.contrato
      ,er.imei_handset   tanapa_recibida
      ,er.imei_sim       sim_recibida
      ,ee.imei_handset   tanapa_entregada
      ,ee.imei_sim       sim_entregada
      ,'UPDATE storage_medium@GDA_AVALON'||chr(10)||'   SET equipment_id = null'||chr(10)||' WHERE equipment_id = (SELECT equipment_id'||chr(10)||'   FROM equipment@GDA_AVALON'||chr(10)||'         WHERE imei = '''||ee.imei_handset||''');'||chr(10) lnk
  from nxsadm.ge_operacion er
      ,nxsadm.ge_cambio_equipo ee
 Where ee.id             = er.id
   And er.numero_gestion in ( SELECT id_gestion_nexus
                              FROM nxsadm.vw_soporte_transacciones
                             WHERE id_contrato       in (&&Contrato)
                                AND error_tx_contrato = 'ar.com.nextel.nexus.business.ReemplazoException: Error: HANDSET SELECCIONADO ASOCIADO A OTRA SIM'
                           )
;
Select * From nxsadm.transaccion where id_gestion_nexus in 
                                                            (SELECT ID_GESTION_NEXUS 
                                                            FROM nxsadm.vw_soporte_transacciones
                                                            WHERE STATUS_TX = 'Finalizada parcialmente'
                                                            and STATUS_FINAL_TX = 'Parcialmente ejecutada'
                                                            and id_contrato IN &&Contrato)
                                                            ;
                                                             

/*
Select * From nxsadm.transaccion where id_gestion_nexus = 75701539; 
         Select co.*,
             'update nxsadm.transaccion_contrato   set STATUS = 1,  FINALIZATION_STATUS = 0 where ID = '||co.id||';'  "PARA DEJAR PENDIENTE"
      From nxsadm.transaccion_contrato co where co.id_transaction  in  (Select ID  From nxsadm.transaccion where id_gestion_nexus = &&id_gestion) ;
      
      
0   Indeterminado         
1   ¿xito                 
2   Parcialmente ejecutada
3   No ejecutada          
4   Fallo          

0   Indeterminado          
1   Pendiente              
2   En ejecuci¢n           
3   Finalizada parcialmente
4   Finalizada             
5   Encolado
