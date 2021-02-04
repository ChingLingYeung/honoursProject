--RevMurphi.MurphiModular.GenConst
  ---- System access constants
  const
    ENABLE_QS: true;
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
      AccessType: enum {
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
        PutSL1C1, 
        Inv_AckL1C1, 
        GetM_Ack_DL1C1, 
        GetS_AckL1C1, 
        WBL1C1, 
        PutML1C1, 
        GetM_Ack_ADL1C1, 
        InvL1C1, 
        Put_AckL1C1, 
        Fwd_GetSL1C1, 
        Fwd_GetML1C1
      };
      
      ------RevMurphi.MurphiModular.Types.Enums.SubEnums.GenArchEnums
      s_cacheL1C1: enum {
        cacheL1C1_S_store_GetM_Ack_AD,
        cacheL1C1_S_store,
        cacheL1C1_S_evict,
        cacheL1C1_S,
        cacheL1C1_M_evict,
        cacheL1C1_M,
        cacheL1C1_I_x_S_evict,
        cacheL1C1_I_x_M_evict,
        cacheL1C1_I_store_GetM_Ack_AD,
        cacheL1C1_I_store,
        cacheL1C1_I_load,
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
    
    ----RevMurphi.MurphiModular.Types.GenAccessType
      v_MACH_MULTISET: multiset[4] of Machines;
      cnt_MACH_MULTISET: 0..4;
      
      Access_Machine: record
        store: array[Address] of v_MACH_MULTISET;
        load: array[Address] of v_MACH_MULTISET;
      end;
    
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
      NET_Ordered: array[Machines] of array[Machines] of array[0..O_NET_MAX-1] of Message;
      NET_Ordered_cnt: array[Machines] of array[Machines] of 0..O_NET_MAX;
      NET_Unordered: array[Machines] of multiset[U_NET_MAX] of Message;
    
    ----RevMurphi.MurphiModular.Types.GenFIFO
      FIFO: record
        Queue: array[0..0] of Message;
        QueueInd: 0..0+1;
      end;
      NET_FIFO: array[Machines] of FIFO;
      
    
    ----RevMurphi.MurphiModular.Types.GenMachines
      v_directoryL1C1_cacheL1C1: multiset[NrCachesL1C1] of Machines;
      cnt_v_directoryL1C1_cacheL1C1: 0..NrCachesL1C1;
      
      ENTRY_directoryL1C1: record
        State: s_directoryL1C1;
        cl: ClValue;
        cacheL1C1: v_directoryL1C1_cacheL1C1;
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
      fwd: NET_Ordered;
      cnt_fwd: NET_Ordered_cnt;
      resp: NET_Ordered;
      cnt_resp: NET_Ordered_cnt;
      req: NET_Ordered;
      cnt_req: NET_Ordered_cnt;
    
      buf_fwd: NET_FIFO;
      buf_resp: NET_FIFO;
      buf_req: NET_FIFO;
    
      g_access: Access_Machine;
      i_cacheL1C1: OBJ_cacheL1C1;
      i_directoryL1C1: OBJ_directoryL1C1;
  
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
    
  ----RevMurphi.MurphiModular.Functions.GenAccessFunc
    procedure Set_store_exe(adr: Address; n:Machines);
    begin
      alias g_st:g_access.store[adr] do
        if MultiSetCount(i:g_st, g_st[i] = n) = 0 then
          MultiSetAdd(n, g_st);
        endif;
      endalias;
    end;
    
    procedure Clear_store(adr: Address; n:Machines);
    begin
      alias g_st:g_access.store[adr] do
        if MultiSetCount(i:g_st, g_st[i] = n) = 1 then
          MultiSetRemovePred(i:g_st, g_st[i] = n);
        endif;
      endalias;
    end;
    
    procedure Set_load_exe(adr: Address; n:Machines);
    begin
      alias g_st:g_access.load[adr] do
        if MultiSetCount(i:g_st, g_st[i] = n) = 0 then
          MultiSetAdd(n, g_st);
        endif;
      endalias;
    end;
    
    procedure Clear_load(adr: Address; n:Machines);
    begin
      alias g_st:g_access.load[adr] do
        if MultiSetCount(i:g_st, g_st[i] = n) = 1 then
          MultiSetRemovePred(i:g_st, g_st[i] = n);
        endif;
      endalias;
    end;
    
    procedure Set_store(adr: Address; n:Machines);
    begin
      Clear_load(adr, n);
      Set_store_exe(adr, n);
    end;
    
    procedure Set_load(adr: Address; n:Machines);
    begin
      Clear_store(adr, n);
      Set_load_exe(adr, n);
    end;
    
    procedure Clear_acc(adr: Address; n:Machines);
    begin
      Clear_store(adr, n);
      Clear_load(adr, n);
    end;
    
    procedure Reset_acc();
    begin
      for a:Address do
        undefine g_access.store[a];
      endfor;
    
      for a:Address do
        undefine g_access.load[a];
      endfor;
    end;
  
  ----RevMurphi.MurphiModular.Functions.GenVectorFunc
    -- .add()
    procedure AddElement_directoryL1C1_cacheL1C1(var sv:v_directoryL1C1_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 0 then
          MultiSetAdd(n, sv);
        endif;
    end;
    
    -- .del()
    procedure RemoveElement_directoryL1C1_cacheL1C1(var sv:v_directoryL1C1_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 1 then
          MultiSetRemovePred(i:sv, sv[i] = n);
        endif;
    end;
    
    -- .clear()
    procedure ClearVector_directoryL1C1_cacheL1C1(var sv:v_directoryL1C1_cacheL1C1;);
    begin
        MultiSetRemovePred(i:sv, true);
    end;
    
    -- .contains()
    function IsElement_directoryL1C1_cacheL1C1(var sv:v_directoryL1C1_cacheL1C1; n:Machines) : boolean;
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
    function HasElement_directoryL1C1_cacheL1C1(var sv:v_directoryL1C1_cacheL1C1; n:Machines) : boolean;
    begin
        if MultiSetCount(i:sv, true) = 0 then
          return false;
        endif;
    
        return true;
    end;
    
    -- .count()
    function VectorCount_directoryL1C1_cacheL1C1(var sv:v_directoryL1C1_cacheL1C1) : cnt_v_directoryL1C1_cacheL1C1;
    begin
        return MultiSetCount(i:sv, true);
    end;
    
  ----RevMurphi.MurphiModular.Functions.GenFIFOFunc
    function PushQueue(var f: NET_FIFO; n:Machines; msg:Message): boolean;
    begin
      alias p:f[n] do
      alias q: p.Queue do
      alias qind: p.QueueInd do
    
        if (qind<=0) then
          q[qind]:=msg;
          qind:=qind+1;
          return true;
        endif;
    
        return false;
    
      endalias;
      endalias;
      endalias;
    end;
    
    function GetQueue(var f: NET_FIFO; n:Machines): Message;
    var
      msg: Message;
    begin
      alias p:f[n] do
      alias q: p.Queue do
      undefine msg;
    
      if !isundefined(q[0].mtype) then
        return q[0];
      endif;
    
      return msg;
      endalias;
      endalias;
    end;
    
    procedure PopQueue(var f: NET_FIFO; n:Machines);
    begin
      alias p:f[n] do
      alias q: p.Queue do
      alias qind: p.QueueInd do
    
    
      for i := 0 to qind-1 do
          if i < qind-1 then
            q[i] := q[i+1];
          else
            undefine q[i];
          endif;
        endfor;
        qind := qind - 1;
    
      endalias;
      endalias;
      endalias;
    end;
  
  
    procedure Reset_buf_();
    begin
      for i:Machines do
          undefine buf_resp[i].Queue;
          buf_resp[i].QueueInd:=0;
      endfor;
    
      for i:Machines do
          undefine buf_fwd[i].Queue;
          buf_fwd[i].QueueInd:=0;
      endfor;
    
      for i:Machines do
          undefine buf_req[i].Queue;
          buf_req[i].QueueInd:=0;
      endfor;
    
    
    end;
  
  
  ----RevMurphi.MurphiModular.Functions.GenNetworkFunc
    procedure Send_fwd(msg:Message; src: Machines;);
      Assert(cnt_fwd[msg.dst][src] < O_NET_MAX) "Too many messages";
      fwd[msg.dst][src][cnt_fwd[msg.dst][src]] := msg;
      cnt_fwd[msg.dst][src] := cnt_fwd[msg.dst][src] + 1;
    end;
    
    procedure Pop_fwd(dst:Machines; src: Machines;);
    begin
      Assert (cnt_fwd[dst][src] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_fwd[dst][src]-1 do
        if i < cnt_fwd[dst][src]-1 then
          fwd[dst][src][i] := fwd[dst][src][i+1];
        else
          undefine fwd[dst][src][i];
        endif;
      endfor;
      cnt_fwd[dst][src] := cnt_fwd[dst][src] - 1;
    end;
    
    procedure Send_resp(msg:Message; src: Machines;);
      Assert(cnt_resp[msg.dst][src] < O_NET_MAX) "Too many messages";
      resp[msg.dst][src][cnt_resp[msg.dst][src]] := msg;
      cnt_resp[msg.dst][src] := cnt_resp[msg.dst][src] + 1;
    end;
    
    procedure Pop_resp(dst:Machines; src: Machines;);
    begin
      Assert (cnt_resp[dst][src] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_resp[dst][src]-1 do
        if i < cnt_resp[dst][src]-1 then
          resp[dst][src][i] := resp[dst][src][i+1];
        else
          undefine resp[dst][src][i];
        endif;
      endfor;
      cnt_resp[dst][src] := cnt_resp[dst][src] - 1;
    end;
    
    procedure Send_req(msg:Message; src: Machines;);
      Assert(cnt_req[msg.dst][src] < O_NET_MAX) "Too many messages";
      req[msg.dst][src][cnt_req[msg.dst][src]] := msg;
      cnt_req[msg.dst][src] := cnt_req[msg.dst][src] + 1;
    end;
    
    procedure Pop_req(dst:Machines; src: Machines;);
    begin
      Assert (cnt_req[dst][src] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_req[dst][src]-1 do
        if i < cnt_req[dst][src]-1 then
          req[dst][src][i] := req[dst][src][i+1];
        else
          undefine req[dst][src][i];
        endif;
      endfor;
      cnt_req[dst][src] := cnt_req[dst][src] - 1;
    end;
    
    procedure Multicast_fwd_C1(var msg: Message; dst_vect: v_directoryL1C1_cacheL1C1; src: Machines;);
    begin
          for n:Machines do
              if n!=msg.src then
                if MultiSetCount(i:dst_vect, dst_vect[i] = n) = 1 then
                  msg.dst := n;
                  Send_fwd(msg, src);
                endif;
              endif;
          endfor;
    end;
    
    function req_network_ready(): boolean;
    begin
          for dst:Machines do
            for src: Machines do
              if cnt_req[dst][src] >= (O_NET_MAX-2) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;
    
    procedure Reset_NET_();
    begin
      
      undefine resp;
      for dst:Machines do
          for src: Machines do
              cnt_resp[dst][src] := 0;
          endfor;
      endfor;
      
      undefine fwd;
      for dst:Machines do
          for src: Machines do
              cnt_fwd[dst][src] := 0;
          endfor;
      endfor;
      
      undefine req;
      for dst:Machines do
          for src: Machines do
              cnt_req[dst][src] := 0;
          endfor;
      endfor;
    
    end;
    
  
  ----RevMurphi.MurphiModular.Functions.GenMessageConstrFunc
    function RequestL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var msg: Message;
    begin
      msg.adr := adr;
      msg.mtype := mtype;
      msg.src := src;
      msg.dst := dst;
    return msg;
    end;
    
    function AckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var msg: Message;
    begin
      msg.adr := adr;
      msg.mtype := mtype;
      msg.src := src;
      msg.dst := dst;
    return msg;
    end;
    
    function RespL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue) : Message;
    var msg: Message;
    begin
      msg.adr := adr;
      msg.mtype := mtype;
      msg.src := src;
      msg.dst := dst;
      msg.cl := cl;
    return msg;
    end;
    
    function RespAckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue; acksExpectedL1C1: 0..NrCachesL1C1) : Message;
    var msg: Message;
    begin
      msg.adr := adr;
      msg.mtype := mtype;
      msg.src := src;
      msg.dst := dst;
      msg.cl := cl;
      msg.acksExpectedL1C1 := acksExpectedL1C1;
    return msg;
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
          cbe.State := directoryL1C1_M;
          return true;
        
        case GetSL1C1:
          AddElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.State := directoryL1C1_S;
          return true;
        
        case PutML1C1:
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_fwd(msg, m);
          if !(cbe.ownerL1C1 = inmsg.src) then
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if (cbe.ownerL1C1 = inmsg.src) then
            cbe.cl := inmsg.cl;
            cbe.State := directoryL1C1_I;
            return true;
          endif;
        
        case PutSL1C1:
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_fwd(msg, m);
          RemoveElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if (VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
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
          cbe.State := directoryL1C1_M;
          return true;
        
        case GetSL1C1:
          msg := RequestL1C1(adr,Fwd_GetSL1C1,inmsg.src,cbe.ownerL1C1);
          Send_fwd(msg, m);
          AddElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          AddElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          cbe.State := directoryL1C1_M_GetS;
          return true;
        
        case PutML1C1:
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_fwd(msg, m);
          if !(cbe.ownerL1C1 = inmsg.src) then
            cbe.State := directoryL1C1_M;
            return true;
          endif;
          if (cbe.ownerL1C1 = inmsg.src) then
            cbe.cl := inmsg.cl;
            cbe.State := directoryL1C1_I;
            return true;
          endif;
        
        case PutSL1C1:
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_fwd(msg, m);
          if (cbe.ownerL1C1 = inmsg.src) then
            cbe.cl := inmsg.cl;
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(cbe.ownerL1C1 = inmsg.src) then
            cbe.State := directoryL1C1_M;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_GetS:
      switch inmsg.mtype
        case WBL1C1:
          if (inmsg.src = cbe.ownerL1C1) then
            cbe.cl := inmsg.cl;
            cbe.State := directoryL1C1_S;
            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            cbe.State := directoryL1C1_M_GetS;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S:
      switch inmsg.mtype
        case GetML1C1:
          if (IsElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            RemoveElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            if (VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
              msg := RespL1C1(adr,GetM_Ack_DL1C1,m,inmsg.src,cbe.cl);
              Send_resp(msg, m);
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_directoryL1C1_cacheL1C1(cbe.cacheL1C1);
              cbe.State := directoryL1C1_M;
              return true;
            endif;
            if !(VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
              msg := RespAckL1C1(adr,GetM_Ack_ADL1C1,m,inmsg.src,cbe.cl,VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1));
              Send_resp(msg, m);
              msg := AckL1C1(adr,InvL1C1,inmsg.src,inmsg.src);
              Multicast_fwd_C1(msg, cbe.cacheL1C1, m);
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_directoryL1C1_cacheL1C1(cbe.cacheL1C1);
              cbe.State := directoryL1C1_M;
              return true;
            endif;
          endif;
          if !(IsElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            msg := RespAckL1C1(adr,GetM_Ack_ADL1C1,m,inmsg.src,cbe.cl,VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1));
            Send_resp(msg, m);
            msg := AckL1C1(adr,InvL1C1,inmsg.src,inmsg.src);
            Multicast_fwd_C1(msg, cbe.cacheL1C1, m);
            cbe.ownerL1C1 := inmsg.src;
            ClearVector_directoryL1C1_cacheL1C1(cbe.cacheL1C1);
            cbe.State := directoryL1C1_M;
            return true;
          endif;
        
        case GetSL1C1:
          AddElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.State := directoryL1C1_S;
          return true;
        
        case PutML1C1:
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_fwd(msg, m);
          RemoveElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if !(VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
            cbe.State := directoryL1C1_S;
            return true;
          endif;
          if (VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
            cbe.State := directoryL1C1_I;
            return true;
          endif;
        
        case PutSL1C1:
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_fwd(msg, m);
          RemoveElement_directoryL1C1_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          if !(VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
            cbe.State := directoryL1C1_S;
            return true;
          endif;
          if (VectorCount_directoryL1C1_cacheL1C1(cbe.cacheL1C1) = 0) then
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
      
      case cacheL1C1_I_load:
      switch inmsg.mtype
        case GetS_AckL1C1:
          cbe.cl := inmsg.cl;
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
            cbe.State := cacheL1C1_I_store_GetM_Ack_AD;
            return true;
          endif;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            cbe.State := cacheL1C1_M;
            return true;
          endif;
        
        case GetM_Ack_DL1C1:
          cbe.cl := inmsg.cl;
          cbe.State := cacheL1C1_M;
          return true;
        
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          cbe.State := cacheL1C1_I_store;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_store_GetM_Ack_AD:
      switch inmsg.mtype
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            cbe.State := cacheL1C1_I_store_GetM_Ack_AD;
            return true;
          endif;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            cbe.State := cacheL1C1_M;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_x_M_evict:
      switch inmsg.mtype
        case Put_AckL1C1:
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_x_S_evict:
      switch inmsg.mtype
        case Put_AckL1C1:
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_M:
      switch inmsg.mtype
        case Fwd_GetML1C1:
          msg := RespL1C1(adr,GetM_Ack_DL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case Fwd_GetSL1C1:
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          msg := RespL1C1(adr,WBL1C1,m,directoryL1C1,cbe.cl);
          Send_resp(msg, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_M_evict:
      switch inmsg.mtype
        case Fwd_GetML1C1:
          msg := RespL1C1(adr,GetM_Ack_DL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.State := cacheL1C1_I_x_M_evict;
          return true;
        
        case Fwd_GetSL1C1:
          msg := RespL1C1(adr,GetS_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          msg := RespL1C1(adr,WBL1C1,m,directoryL1C1,cbe.cl);
          Send_resp(msg, m);
          cbe.State := cacheL1C1_S_evict;
          return true;
        
        case Put_AckL1C1:
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_evict:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.State := cacheL1C1_I_x_S_evict;
          return true;
        
        case Put_AckL1C1:
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_store:
      switch inmsg.mtype
        case GetM_Ack_ADL1C1:
          cbe.acksExpectedL1C1 := inmsg.acksExpectedL1C1;
          if !(cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            cbe.State := cacheL1C1_S_store_GetM_Ack_AD;
            return true;
          endif;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            cbe.State := cacheL1C1_M;
            return true;
          endif;
        
        case GetM_Ack_DL1C1:
          cbe.State := cacheL1C1_M;
          return true;
        
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          cbe.State := cacheL1C1_I_store;
          return true;
        
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          cbe.State := cacheL1C1_S_store;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_store_GetM_Ack_AD:
      switch inmsg.mtype
        case Inv_AckL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
            cbe.State := cacheL1C1_S_store_GetM_Ack_AD;
            return true;
          endif;
          if (cbe.acksExpectedL1C1 = cbe.acksReceivedL1C1) then
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
    procedure FSM_Access_cacheL1C1_I_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr,GetSL1C1,m,directoryL1C1);
      Send_req(msg, m);
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
      cbe.State := cacheL1C1_I_store;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RespL1C1(adr,PutML1C1,m,directoryL1C1,cbe.cl);
      Send_req(msg, m);
      cbe.State := cacheL1C1_M_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr,PutSL1C1,m,directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_S_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
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
      cbe.State := cacheL1C1_S_store;
    endalias;
    end;
    
  ----RevMurphi.MurphiModular.StateMachines.GenAccessRuleSet
    ruleset m:OBJSET_cacheL1C1 do
    ruleset adr:Address do
      alias cbe:i_cacheL1C1[m].cb[adr] do
    
      rule "cacheL1C1_I_store"
        cbe.State = cacheL1C1_I
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_I_store(adr, m);
      endrule;
    
      rule "cacheL1C1_I_load"
        cbe.State = cacheL1C1_I
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_I_load(adr, m);
      endrule;
    
      rule "cacheL1C1_M_evict"
        cbe.State = cacheL1C1_M
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_M_evict(adr, m);
      endrule;
    
      rule "cacheL1C1_M_store"
        cbe.State = cacheL1C1_M
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_M_store(adr, m);
      endrule;
    
      rule "cacheL1C1_M_load"
        cbe.State = cacheL1C1_M
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_M_load(adr, m);
      endrule;
    
      rule "cacheL1C1_S_store"
        cbe.State = cacheL1C1_S
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_S_store(adr, m);
      endrule;
    
      rule "cacheL1C1_S_evict"
        cbe.State = cacheL1C1_S
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_S_evict(adr, m);
      endrule;
    
      rule "cacheL1C1_S_load"
        cbe.State = cacheL1C1_S
        & req_network_ready()
      ==>
        FSM_Access_cacheL1C1_S_load(adr, m);
      endrule;
    
    
      endalias;
    endruleset;
    endruleset;
    

--RevMurphi.MurphiModular.GenNetworkRules

  ----RevMurphi.MurphiModular.NetworkRules.GenNetworkRule
    
    ruleset dst:Machines do
      alias p:buf_resp[dst] do
    
          rule "buf_resp"
            (p.QueueInd>0)
          ==>
            alias msg:p.Queue[0] do
              if IsMember(dst, OBJSET_directoryL1C1) then
                if FSM_MSG_directoryL1C1(msg, dst) then
                  PopQueue(buf_resp, dst);
                endif;
              elsif IsMember(dst, OBJSET_cacheL1C1) then
                if FSM_MSG_cacheL1C1(msg, dst) then
                  PopQueue(buf_resp, dst);
                endif;
    
              else error "unknown machine";
              endif;
            endalias;
          endrule;
    
      endalias;
    endruleset;
    
    ruleset dst:Machines do
      alias p:buf_fwd[dst] do
    
          rule "buf_fwd"
            (p.QueueInd>0)
          ==>
            alias msg:p.Queue[0] do
              if IsMember(dst, OBJSET_directoryL1C1) then
                if FSM_MSG_directoryL1C1(msg, dst) then
                  PopQueue(buf_fwd, dst);
                endif;
              elsif IsMember(dst, OBJSET_cacheL1C1) then
                if FSM_MSG_cacheL1C1(msg, dst) then
                  PopQueue(buf_fwd, dst);
                endif;
    
              else error "unknown machine";
              endif;
            endalias;
          endrule;
    
      endalias;
    endruleset;
    
    ruleset dst:Machines do
      alias p:buf_req[dst] do
    
          rule "buf_req"
            (p.QueueInd>0)
          ==>
            alias msg:p.Queue[0] do
              if IsMember(dst, OBJSET_directoryL1C1) then
                if FSM_MSG_directoryL1C1(msg, dst) then
                  PopQueue(buf_req, dst);
                endif;
              elsif IsMember(dst, OBJSET_cacheL1C1) then
                if FSM_MSG_cacheL1C1(msg, dst) then
                  PopQueue(buf_req, dst);
                endif;
    
              else error "unknown machine";
              endif;
            endalias;
          endrule;
    
      endalias;
    endruleset;
    
    ruleset dst:Machines do
        ruleset src: Machines do
            alias msg:resp[dst][src][0] do
              rule "Receive resp"
                cnt_resp[dst][src] > 0
              ==>
            if PushQueue(buf_resp, dst, msg) then
              Pop_resp(dst, src);
            endif;
    
              endrule;
            endalias;
        endruleset;
    endruleset;
    
    ruleset dst:Machines do
        ruleset src: Machines do
            alias msg:fwd[dst][src][0] do
              rule "Receive fwd"
                cnt_fwd[dst][src] > 0
              ==>
            if PushQueue(buf_fwd, dst, msg) then
              Pop_fwd(dst, src);
            endif;
    
              endrule;
            endalias;
        endruleset;
    endruleset;
    
    ruleset dst:Machines do
        ruleset src: Machines do
            alias msg:req[dst][src][0] do
              rule "Receive req"
                cnt_req[dst][src] > 0
              ==>
            if PushQueue(buf_req, dst, msg) then
              Pop_req(dst, src);
            endif;
    
              endrule;
            endalias;
        endruleset;
    endruleset;
    

--RevMurphi.MurphiModular.GenStartStates

  startstate
    Reset_acc();
    Reset_NET_();
    Reset_buf_();
    Reset_directoryL1C1();
    Reset_cacheL1C1();
  endstartstate;

--RevMurphi.MurphiModular.GenInvariant
  
  invariant "Single Writer"
    forall a:Address do
      !MultiSetCount(i:g_access.store[a], true) > 1
    endforall;
  
  
  
  invariant "Exclusive Write"
    forall a:Address do
      MultiSetCount(i:g_access.store[a], true) > 0
      ->
      MultiSetCount(i:g_access.load[a], true) = 0
    endforall;
