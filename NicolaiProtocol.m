--RevMurphi.MurphiModular.Constants.GenConst
  ---- System access constants
  const
    ENABLE_QS: false;
    VAL_COUNT: 1;
    ADR_COUNT: 1;
  
  ---- System network constants
    O_NET_MAX: 4;
    U_NET_MAX: 4;
  
  ---- SSP declaration constants
    NrCachesL1C1: 3;
  
--RevMurphi.MurphiModular.GenTypes
  type
    ----RevMurphi.MurphiModular.Types.GenAdrDef
    Address: scalarset(ADR_COUNT);
    ClValue: 0..VAL_COUNT;
    
    ----RevMurphi.MurphiModular.Types.Enums.GenEnums
      ------RevMurphi.MurphiModular.Types.Enums.SubEnums.GenAccess
      PermissionType: enum {
        none,
        load,
        acquire,
        store,
        release,
        fence};
      
      ------RevMurphi.MurphiModular.Types.Enums.SubEnums.GenMessageTypes
      MessageType: enum {
        GetSL1C1, 
        GetML1C1, 
        PutIL1C1, 
        PutSL1C1, 
        Inv_AckL1C1, 
        GetM_Ack_DL1C1, 
        GetS_AckL1C1, 
        WBL1C1, 
        PutML1C1, 
        PutI_AckL1C1, 
        GetM_Ack_ADL1C1, 
        InvL1C1, 
        PutS_AckL1C1, 
        Fwd_GetSL1C1, 
        Fwd_GetML1C1, 
        PutM_AckL1C1
      };
      
      ------RevMurphi.MurphiModular.Types.Enums.SubEnums.GenArchEnums
      s_cacheL1C1: enum {
        cacheL1C1_S_store_GetM_Ack_AD,
        cacheL1C1_S_store,
        cacheL1C1_S_evict,
        cacheL1C1_S,
        cacheL1C1_M_evict,
        cacheL1C1_M,
        cacheL1C1_I_store_GetM_Ack_AD,
        cacheL1C1_I_store,
        cacheL1C1_I_load,
        cacheL1C1_I_evict,
        cacheL1C1_I
      };
      
      s_directoryL1C1: enum {
        directoryL1C1_S,
        directoryL1C1_M_GetS,
        directoryL1C1_M,
        directoryL1C1_I
      };
      
    ----RevMurphi.MurphiModular.Types.GenMachineSets
      -- Cluster: C1
      OBJSET_cacheL1C1: scalarset(3);
      OBJSET_directoryL1C1: enum{directoryL1C1};
      C1Machines: union{OBJSET_cacheL1C1, OBJSET_directoryL1C1};
      
      Machines: union{OBJSET_cacheL1C1, OBJSET_directoryL1C1};
    
    ----RevMurphi.MurphiModular.Types.GenCheckTypes
      ------RevMurphi.MurphiModular.Types.CheckTypes.GenPermType
        acc_type_obj: multiset[3] of PermissionType;
        PermMonitor: array[Machines] of array[Address] of acc_type_obj;
      
      ------RevMurphi.MurphiModular.Types.CheckTypes.GenStoreMonitorType
        GlobalStoreMonitor: array[Address] of ClValue;
      
    
    ----RevMurphi.MurphiModular.Types.GenMessage
      Message: record
        adr: Address;
        mtype: MessageType;
        src: Machines;
        dst: Machines;
        cl: ClValue;
        acksExpectedL1C1: 0..NrCachesL1C1;
      end;
      
    ----RevMurphi.MurphiModular.Types.GenNetwork
      NET_Ordered: array[Machines] of array[0..O_NET_MAX-1] of Message;
      NET_Ordered_cnt: array[Machines] of 0..O_NET_MAX;
      NET_Unordered: array[Machines] of multiset[U_NET_MAX] of Message;
    
    ----RevMurphi.MurphiModular.Types.GenMachines
      v_cacheL1C1: multiset[NrCachesL1C1] of Machines;
      cnt_v_cacheL1C1: 0..NrCachesL1C1;
      
      ENTRY_directoryL1C1: record
        State: s_directoryL1C1;
        cl: ClValue;
        cacheL1C1: v_cacheL1C1;
        ownerL1C1: Machines;
      end;
      
      MACH_directoryL1C1: record
        cb: array[Address] of ENTRY_directoryL1C1;
      end;
      
      OBJ_directoryL1C1: array[OBJSET_directoryL1C1] of MACH_directoryL1C1;
      
      ENTRY_cacheL1C1: record
        State: s_cacheL1C1;
        cl: ClValue;
        acksReceivedL1C1: 0..NrCachesL1C1;
        acksExpectedL1C1: 0..NrCachesL1C1;
      end;
      
      MACH_cacheL1C1: record
        cb: array[Address] of ENTRY_cacheL1C1;
      end;
      
      OBJ_cacheL1C1: array[OBJSET_cacheL1C1] of MACH_cacheL1C1;
    

  var
    --RevMurphi.MurphiModular.GenVars
      put_vc: NET_Ordered;
      cnt_put_vc: NET_Ordered_cnt;
      fwd: NET_Unordered;
      inv: NET_Unordered;
      resp: NET_Unordered;
      req: NET_Unordered;
    
    
      g_perm: PermMonitor;
      g_monitor_store: GlobalStoreMonitor;
      i_directoryL1C1: OBJ_directoryL1C1;
      i_cacheL1C1: OBJ_cacheL1C1;
  
--RevMurphi.MurphiModular.GenFunctions

  ----RevMurphi.MurphiModular.Functions.GenResetFunc
    procedure Reset_directoryL1C1();
    begin
      for i:OBJSET_directoryL1C1 do
        for a:Address do
          i_directoryL1C1[i].cb[a].State := directoryL1C1_I;
          i_directoryL1C1[i].cb[a].cl := 0;
    
        endfor;
      endfor;
    end;
    
    procedure Reset_cacheL1C1();
    begin
      for i:OBJSET_cacheL1C1 do
        for a:Address do
          i_cacheL1C1[i].cb[a].State := cacheL1C1_I;
          i_cacheL1C1[i].cb[a].cl := 0;
          i_cacheL1C1[i].cb[a].acksReceivedL1C1 := 0;
          i_cacheL1C1[i].cb[a].acksExpectedL1C1 := 0;
    
        endfor;
      endfor;
    end;
    
  ----RevMurphi.MurphiModular.Functions.GenPermFunc
    procedure Clear_perm(adr: Address; m: Machines);
    begin
      alias l_perm_set:g_perm[m][adr] do
          undefine l_perm_set;
      endalias;
    end;
    
    procedure Set_perm(acc_type: PermissionType; adr: Address; m: Machines);
    begin
      alias l_perm_set:g_perm[m][adr] do
          MultisetAdd(acc_type, l_perm_set);
      endalias;
    end;
    
    procedure Reset_perm();
    begin
      for m:Machines do
        for adr:Address do
          Clear_perm(adr, m);
        endfor;
      endfor;
    end;
    
  
  ----RevMurphi.MurphiModular.Functions.GenStoreMonitorFunc
    procedure Execute_store_monitor(cb: ClValue; adr: Address);
    begin
      alias cbe: g_monitor_store[adr] do
        if cbe = cb then
          if cbe = VAL_COUNT then
            cbe := 0;
          else
            cbe := cbe + 1;
          endif;
        else
            error "Write linearization failed";
        endif;
      endalias;
    end;
    
    procedure Reset_global_monitor();
    begin
      for adr:Address do
        g_monitor_store[adr] := 0;
      endfor;
    end;
  
    procedure Store(var cbe: ClValue; adr: Address);
    begin
      Execute_store_monitor(cbe, adr);
      if cbe = VAL_COUNT then
        cbe:= 0;
      else
        cbe := cbe + 1;
      endif;
    end;
  
  ----RevMurphi.MurphiModular.Functions.GenVectorFunc
    -- .add()
    procedure AddElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 0 then
          MultiSetAdd(n, sv);
        endif;
    end;
    
    -- .del()
    procedure RemoveElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 1 then
          MultiSetRemovePred(i:sv, sv[i] = n);
        endif;
    end;
    
    -- .clear()
    procedure ClearVector_cacheL1C1(var sv:v_cacheL1C1;);
    begin
        MultiSetRemovePred(i:sv, true);
    end;
    
    -- .contains()
    function IsElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines) : boolean;
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 1 then
          return true;
        elsif MultiSetCount(i:sv, sv[i] = n) = 0 then
          return false;
        else
          Error "Multiple Entries of Sharer in SV multiset";
        endif;
      return false;
    end;
    
    -- .empty()
    function HasElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines) : boolean;
    begin
        if MultiSetCount(i:sv, true) = 0 then
          return false;
        endif;
    
        return true;
    end;
    
    -- .count()
    function VectorCount_cacheL1C1(var sv:v_cacheL1C1) : cnt_v_cacheL1C1;
    begin
        return MultiSetCount(i:sv, true);
    end;
    
  ----RevMurphi.MurphiModular.Functions.GenFIFOFunc
  ----RevMurphi.MurphiModular.Functions.GenNetworkFunc
    procedure Send_put_vc(msg:Message; src: Machines;);
      Assert(cnt_put_vc[msg.dst] < O_NET_MAX) "Too many messages";
      put_vc[msg.dst][cnt_put_vc[msg.dst]] := msg;
      cnt_put_vc[msg.dst] := cnt_put_vc[msg.dst] + 1;
    end;
    
    procedure Pop_put_vc(dst:Machines; src: Machines;);
    begin
      Assert (cnt_put_vc[dst] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_put_vc[dst]-1 do
        if i < cnt_put_vc[dst]-1 then
          put_vc[dst][i] := put_vc[dst][i+1];
        else
          undefine put_vc[dst][i];
        endif;
      endfor;
      cnt_put_vc[dst] := cnt_put_vc[dst] - 1;
    end;
    
    procedure Send_fwd(msg:Message; src: Machines;);
      Assert (MultiSetCount(i:fwd[msg.dst], true) < U_NET_MAX) "Too many messages";
      MultiSetAdd(msg, fwd[msg.dst]);
    end;
    
    procedure Send_inv(msg:Message; src: Machines;);
      Assert (MultiSetCount(i:inv[msg.dst], true) < U_NET_MAX) "Too many messages";
      MultiSetAdd(msg, inv[msg.dst]);
    end;
    
    procedure Send_resp(msg:Message; src: Machines;);
      Assert (MultiSetCount(i:resp[msg.dst], true) < U_NET_MAX) "Too many messages";
      MultiSetAdd(msg, resp[msg.dst]);
    end;
    
    procedure Send_req(msg:Message; src: Machines;);
      Assert (MultiSetCount(i:req[msg.dst], true) < U_NET_MAX) "Too many messages";
      MultiSetAdd(msg, req[msg.dst]);
    end;
    
    procedure Multicast_inv_C1(var msg: Message; dst_vect: v_cacheL1C1; src: Machines;);
    begin
          for n:Machines do
              if n!=msg.src then
                if MultiSetCount(i:dst_vect, dst_vect[i] = n) = 1 then
                  msg.dst := n;
                  Send_inv(msg, src);
                endif;
              endif;
          endfor;
    end;
    
    function inv_network_ready(): boolean;
    begin
          for mach:Machines do
            alias mul_set:inv[mach] do
              if MultisetCount(i:mul_set, isundefined(mul_set[i].mtype)) >= (U_NET_MAX-2) then
                return false;
              endif;
            endalias;
          endfor;
    
          return true;
    end;
    function resp_network_ready(): boolean;
    begin
          for mach:Machines do
            alias mul_set:resp[mach] do
              if MultisetCount(i:mul_set, isundefined(mul_set[i].mtype)) >= (U_NET_MAX-2) then
                return false;
              endif;
            endalias;
          endfor;
    
          return true;
    end;
    function req_network_ready(): boolean;
    begin
          for mach:Machines do
            alias mul_set:req[mach] do
              if MultisetCount(i:mul_set, isundefined(mul_set[i].mtype)) >= (U_NET_MAX-2) then
                return false;
              endif;
            endalias;
          endfor;
    
          return true;
    end;
    function fwd_network_ready(): boolean;
    begin
          for mach:Machines do
            alias mul_set:fwd[mach] do
              if MultisetCount(i:mul_set, isundefined(mul_set[i].mtype)) >= (U_NET_MAX-2) then
                return false;
              endif;
            endalias;
          endfor;
    
          return true;
    end;
    function put_vc_network_ready(): boolean;
    begin
          for dst:Machines do
            for src: Machines do
              if cnt_put_vc[dst] >= (O_NET_MAX-2) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;
    function network_ready(): boolean;
    begin
            if !inv_network_ready() then
            return false;
          endif;
    
    
          if !resp_network_ready() then
            return false;
          endif;
    
    
          if !req_network_ready() then
            return false;
          endif;
    
    
          if !fwd_network_ready() then
            return false;
          endif;
    
    
          if !put_vc_network_ready() then
            return false;
          endif;
    
    
    
      return true;
    end;
    
    procedure Reset_NET_();
    begin
      
      undefine put_vc;
      for dst:Machines do
          cnt_put_vc[dst] := 0;
      endfor;
      
      undefine inv;
      
      undefine req;
      
      undefine resp;
      
      undefine fwd;
    
    end;
    
  
  ----RevMurphi.MurphiModular.Functions.GenMessageConstrFunc
    function RequestL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
    return Message;
    end;
    
    function AckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
    return Message;
    end;
    
    function RespL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
      Message.cl := cl;
    return Message;
    end;
    
    function RespAckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue; acksExpectedL1C1: 0..NrCachesL1C1) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
      Message.cl := cl;
      Message.acksExpectedL1C1 := acksExpectedL1C1;
    return Message;
    end;
    
  

--RevMurphi.MurphiModular.GenStateMachines

  ----RevMurphi.MurphiModular.StateMachines.GenMessageStateMachines
    function FSM_MSG_directoryL1C1(inmsg:Message; m:OBJSET_directoryL1C1) : boolean;
    var msg: Message;
    begin
      alias adr: inmsg.adr do
      alias cbe: i_directoryL1C1[m].cb[adr] do
    switch cbe.State
      case directoryL1C1_I:
      switch inmsg.mtype
        case GetML1C1:
          msg := RespL1C1(adr,GetM_Ack_DL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M;
          return true;
        
        case GetSL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;
          return true;
        
        case PutIL1C1:
          msg := AckL1C1(adr,PutI_AckL1C1,m,inmsg.src);
          Send_put_vc(msg, m);
          RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
        
        case PutML1C1:
          msg := AckL1C1(adr,PutI_AckL1C1,m,inmsg.src);
          Send_put_vc(msg, m);
          RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
        
        case PutSL1C1:
          msg := AckL1C1(adr,PutI_AckL1C1,m,inmsg.src);
          Send_put_vc(msg, m);
          RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M:
      switch inmsg.mtype
        case GetML1C1:
          msg := RequestL1C1(adr,Fwd_GetML1C1,inmsg.src,cbe.ownerL1C1);
          Send_fwd(msg, m);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M;
          return true;
        
        case GetSL1C1:
          msg := RequestL1C1(adr,Fwd_GetSL1C1,inmsg.src,cbe.ownerL1C1);
          Send_fwd(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_GetS;
          return true;
        
        case PutIL1C1:
          if (cbe.ownerL1C1 = inmsg.src) then
            msg := AckL1C1(adr,PutM_AckL1C1,m,inmsg.src);
            Send_put_vc(msg, m);
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(cbe.ownerL1C1 = inmsg.src) then
            msg := AckL1C1(adr,PutI_AckL1C1,m,inmsg.src);
            Send_put_vc(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;
            return true;
          endif;
        
        case PutML1C1:
          if (cbe.ownerL1C1 = inmsg.src) then
            msg := AckL1C1(adr,PutM_AckL1C1,m,inmsg.src);
            Send_put_vc(msg, m);
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(cbe.ownerL1C1 = inmsg.src) then
            msg := AckL1C1(adr,PutI_AckL1C1,m,inmsg.src);
            Send_put_vc(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;
            return true;
          endif;
        
        case PutSL1C1:
          if (cbe.ownerL1C1 = inmsg.src) then
            msg := AckL1C1(adr,PutM_AckL1C1,m,inmsg.src);
            Send_put_vc(msg, m);
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(cbe.ownerL1C1 = inmsg.src) then
            msg := AckL1C1(adr,PutI_AckL1C1,m,inmsg.src);
            Send_put_vc(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_GetS:
      switch inmsg.mtype
        case WBL1C1:
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M_GetS;
            return true;
          endif;
          if (inmsg.src = cbe.ownerL1C1) then
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S:
      switch inmsg.mtype
        case GetML1C1:
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
              msg := RespAckL1C1(adr,GetM_Ack_ADL1C1,m,inmsg.src,cbe.cl,VectorCount_cacheL1C1(cbe.cacheL1C1));
              Send_resp(msg, m);
              msg := AckL1C1(adr,InvL1C1,inmsg.src,inmsg.src);
              Multicast_inv_C1(msg, cbe.cacheL1C1, m);
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_M;
              return true;
            endif;
            if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
              msg := RespL1C1(adr,GetM_Ack_DL1C1,m,inmsg.src,cbe.cl);
              Send_resp(msg, m);
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_M;
              return true;
            endif;
          endif;
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            msg := RespAckL1C1(adr,GetM_Ack_ADL1C1,m,inmsg.src,cbe.cl,VectorCount_cacheL1C1(cbe.cacheL1C1));
            Send_resp(msg, m);
            msg := AckL1C1(adr,InvL1C1,inmsg.src,inmsg.src);
            Multicast_inv_C1(msg, cbe.cacheL1C1, m);
            cbe.ownerL1C1 := inmsg.src;
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;
            return true;
          endif;
        
        case GetSL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;
          return true;
        
        case PutIL1C1:
          msg := AckL1C1(adr,PutS_AckL1C1,m,inmsg.src);
          Send_put_vc(msg, m);
          RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;
            return true;
          endif;
        
        case PutML1C1:
          msg := AckL1C1(adr,PutS_AckL1C1,m,inmsg.src);
          Send_put_vc(msg, m);
          RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;
            return true;
          endif;
        
        case PutSL1C1:
          msg := AckL1C1(adr,PutS_AckL1C1,m,inmsg.src);
          Send_put_vc(msg, m);
          RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;
            return true;
          endif;
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
        
        else return false;
      endswitch;
      
    endswitch;
    endalias;
    endalias;
    return false;
    end;
    
    function FSM_MSG_cacheL1C1(inmsg:Message; m:OBJSET_cacheL1C1) : boolean;
    var msg: Message;
    begin
      alias adr: inmsg.adr do
      alias cbe: i_cacheL1C1[m].cb[adr] do
    switch cbe.State
      case cacheL1C1_I:
      switch inmsg.mtype
        else return false;
      endswitch;
      
      case cacheL1C1_I_evict:
      switch inmsg.mtype
        case PutI_AckL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_load:
      switch inmsg.mtype
        case GetS_AckL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_store:
      switch inmsg.mtype
        case GetM_Ack_ADL1C1:
          cbe.cl := inmsg.cl;
          cbe.acksExpectedL1C1 := inmsg.acksExpectedL1C1;
          if !(cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m);
            cbe.State := cacheL1C1_I_store_GetM_Ack_AD;
            return true;
          endif;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
            cbe.State := cacheL1C1_M;
            return true;
          endif;
        
        case GetM_Ack_DL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
          cbe.State := cacheL1C1_M;
          return true;
        
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_store;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_store_GetM_Ack_AD:
      switch inmsg.mtype
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
            cbe.State := cacheL1C1_M;
            return true;
          endif;
          if !(cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m);
            cbe.State := cacheL1C1_I_store_GetM_Ack_AD;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case cacheL1C1_M:
      switch inmsg.mtype
        case Fwd_GetML1C1:
          msg := RespL1C1(adr,GetM_Ack_DL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case Fwd_GetSL1C1:
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          msg := RespL1C1(adr,WBL1C1,m,directoryL1C1,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_M_evict:
      switch inmsg.mtype
        case Fwd_GetML1C1:
          msg := RespL1C1(adr,GetM_Ack_DL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_evict;
          return true;
        
        case Fwd_GetSL1C1:
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          msg := RespL1C1(adr,WBL1C1,m,directoryL1C1,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_S_evict;
          return true;
        
        case PutM_AckL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_evict:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_evict;
          return true;
        
        case PutS_AckL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_store:
      switch inmsg.mtype
        case GetM_Ack_ADL1C1:
          cbe.acksExpectedL1C1 := inmsg.acksExpectedL1C1;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
            cbe.State := cacheL1C1_M;
            return true;
          endif;
          if !(cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m);
            cbe.State := cacheL1C1_S_store_GetM_Ack_AD;
            return true;
          endif;
        
        case GetM_Ack_DL1C1:
          Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
          cbe.State := cacheL1C1_M;
          return true;
        
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_store;
          return true;
        
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_S_store;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_store_GetM_Ack_AD:
      switch inmsg.mtype
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m);
            cbe.State := cacheL1C1_S_store_GetM_Ack_AD;
            return true;
          endif;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
            cbe.State := cacheL1C1_M;
            return true;
          endif;
        
        else return false;
      endswitch;
      
    endswitch;
    endalias;
    endalias;
    return false;
    end;
    
  ----RevMurphi.MurphiModular.StateMachines.GenAccessStateMachines
    procedure FSM_Access_cacheL1C1_I_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr,PutIL1C1,m,directoryL1C1);
      Send_req(msg, m);
      Clear_perm(adr, m);
      cbe.State := cacheL1C1_I_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_I_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr,GetSL1C1,m,directoryL1C1);
      Send_req(msg, m);
      Clear_perm(adr, m);
      cbe.State := cacheL1C1_I_load;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_I_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr,GetML1C1,m,directoryL1C1);
      Send_req(msg, m);
      cbe.acksReceivedL1C1 := 0;
      Clear_perm(adr, m);
      cbe.State := cacheL1C1_I_store;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RespL1C1(adr,PutML1C1,m,directoryL1C1,cbe.cl);
      Send_req(msg, m);
      Clear_perm(adr, m);
      cbe.State := cacheL1C1_M_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
      Store(cbe.cl, adr);
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr,PutSL1C1,m,directoryL1C1);
      Send_req(msg, m);
      Clear_perm(adr, m);
      cbe.State := cacheL1C1_S_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      Clear_perm(adr, m); Set_perm(load, adr, m);
      cbe.State := cacheL1C1_S;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr,GetML1C1,m,directoryL1C1);
      Send_req(msg, m);
      cbe.acksReceivedL1C1 := 0;
      Clear_perm(adr, m);
      cbe.State := cacheL1C1_S_store;
    endalias;
    end;
    

--RevMurphi.MurphiModular.GenResetFunc

  procedure System_Reset();
  begin
  Reset_perm();
  Reset_global_monitor();
  Reset_NET_();
  Reset_cacheL1C1();
  Reset_directoryL1C1();
  end;
  

--RevMurphi.MurphiModular.GenRules
  ----RevMurphi.MurphiModular.Rules.GenAccessRuleSet
    ruleset m:OBJSET_cacheL1C1 do
    ruleset adr:Address do
      alias cbe:i_cacheL1C1[m].cb[adr] do
    
      rule "cacheL1C1_I_load"
        cbe.State = cacheL1C1_I & network_ready()
      ==>
        FSM_Access_cacheL1C1_I_load(adr, m);
      endrule;
    
      rule "cacheL1C1_I_evict"
        cbe.State = cacheL1C1_I & network_ready()
      ==>
        FSM_Access_cacheL1C1_I_evict(adr, m);
      endrule;
    
      rule "cacheL1C1_I_store"
        cbe.State = cacheL1C1_I & network_ready()
      ==>
        FSM_Access_cacheL1C1_I_store(adr, m);
      endrule;
    
      rule "cacheL1C1_M_load"
        cbe.State = cacheL1C1_M 
      ==>
        FSM_Access_cacheL1C1_M_load(adr, m);
      endrule;
    
      rule "cacheL1C1_M_evict"
        cbe.State = cacheL1C1_M & network_ready()
      ==>
        FSM_Access_cacheL1C1_M_evict(adr, m);
      endrule;
    
      rule "cacheL1C1_M_store"
        cbe.State = cacheL1C1_M 
      ==>
        FSM_Access_cacheL1C1_M_store(adr, m);
      endrule;
    
      rule "cacheL1C1_S_store"
        cbe.State = cacheL1C1_S & network_ready()
      ==>
        FSM_Access_cacheL1C1_S_store(adr, m);
      endrule;
    
      rule "cacheL1C1_S_evict"
        cbe.State = cacheL1C1_S & network_ready()
      ==>
        FSM_Access_cacheL1C1_S_evict(adr, m);
      endrule;
    
      rule "cacheL1C1_S_load"
        cbe.State = cacheL1C1_S 
      ==>
        FSM_Access_cacheL1C1_S_load(adr, m);
      endrule;
    
    
      endalias;
    endruleset;
    endruleset;
    
  ----RevMurphi.MurphiModular.Rules.GenNetworkRule
    ruleset dst:Machines do
        ruleset src: Machines do
            alias msg:put_vc[dst][0] do
              rule "Receive put_vc"
                cnt_put_vc[dst] > 0
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                  Pop_put_vc(dst, src);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                  Pop_put_vc(dst, src);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
        endruleset;
    endruleset;
    
    ruleset dst:Machines do
        choose midx:inv[dst] do
            alias mach:inv[dst] do
            alias msg:mach[midx] do
              rule "Receive inv"
                !isundefined(msg.mtype)
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
            endalias;
        endchoose;
    endruleset;
    
    ruleset dst:Machines do
        choose midx:req[dst] do
            alias mach:req[dst] do
            alias msg:mach[midx] do
              rule "Receive req"
                !isundefined(msg.mtype)
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
            endalias;
        endchoose;
    endruleset;
    
    ruleset dst:Machines do
        choose midx:resp[dst] do
            alias mach:resp[dst] do
            alias msg:mach[midx] do
              rule "Receive resp"
                !isundefined(msg.mtype)
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
            endalias;
        endchoose;
    endruleset;
    
    ruleset dst:Machines do
        choose midx:fwd[dst] do
            alias mach:fwd[dst] do
            alias msg:mach[midx] do
              rule "Receive fwd"
                !isundefined(msg.mtype)
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                MultiSetRemove(midx, mach);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
            endalias;
        endchoose;
    endruleset;
    

--RevMurphi.MurphiModular.GenStartStates

  startstate
    System_Reset();
  endstartstate;

--RevMurphi.MurphiModular.GenInvariant
  invariant "exclusive store check"
      forall a:Address do
          forall m1:Machines do
          forall m2:Machines do
          ( m1 != m2
            & MultiSetCount(i:g_perm[m1][a], g_perm[m1][a][i] = store) > 0)
          ->
            MultiSetCount(i:g_perm[m2][a], g_perm[m2][a][i] = store) = 0
          endforall
          endforall
      endforall;
  
  
  
  invariant "store excludes load check"
      forall a:Address do
          forall m1:Machines do
          forall m2:Machines do
          ( m1 != m2
            & MultiSetCount(i:g_perm[m1][a], g_perm[m1][a][i] = store) > 0)
          ->
            MultiSetCount(i:g_perm[m2][a], g_perm[m2][a][i] = load) = 0
          endforall
          endforall
      endforall;
  
