import sys
import networkx as nx
from assignNetwork import assignNetwork

conflicts = []
messageTypes = []
incomingMessages = []
outgoingMessages = []
stableStates = []
graph = {}
G = nx.MultiDiGraph()

assert len(sys.argv[1:]) <= 2, "Too many arguments"
file = sys.argv[1]
if(len(sys.argv[1:]) == 2):
    constraiantFile = sys.argv[2]

with open(file) as f:
    lines = f.readlines()
    line_idx = 0

    while(not "RevMurphi.MurphiModular.Types.Enums.SubEnums.GenMessageTypes" in lines[line_idx]):
        line_idx += 1
    line_idx += 2

    # Get all messages
    while(not ";" in lines[line_idx]):
        msg = lines[line_idx].strip()
        if msg[-1] == ',':
            msg = msg[:-1]
        messageTypes.append(msg)
        line_idx += 1

    print(messageTypes)

    while(not "RevMurphi.MurphiModular.Types.Enums.SubEnums.GenArchEnums" in lines[line_idx]):
        line_idx += 1
    line_idx += 2

    #get stable states
    cacheStates = []
    while not "directory" in lines[line_idx]:
        state = lines[line_idx].strip().replace("cache", "")
        if len(state) == 0:
            line_idx += 1
            continue
        if state[-1] == ',':
            state = state[:-1]
        cacheStates.append(state)
        line_idx += 1
    
    line_idx += 1
    while not ";" in lines[line_idx]:
        state = lines[line_idx].strip().replace("directory", "")
        if state[-1] == ',':
            state = state[:-1]
        if state in cacheStates:
            stableStates.append("cache" + state)
        line_idx += 1


    #find and parse state machines
    while(not "----RevMurphi.MurphiModular.StateMachines.GenMessageStateMachines" in lines[line_idx]):
        # print(i, lines[i])
        line_idx += 1

    for i in range(line_idx, len(lines)):
        #find switch cbe.State then find inmsg.mtype
        if ("case cache" in lines[i]): #don't need to check directory or "case directory" in lines[i]
            inState = lines[i].strip()[5:-1]
            outState = ""
            edge = ""

            print("state: " + inState)
            i += 1

            incoming = False
            prev_message = ""
            msg_types = {}

            for msgType in messageTypes:
                msg_types[msgType] = "stall"

            while(not "endswitch;" in lines[i]):
                if("case" in lines[i]):
                    incoming_msg = lines[i].strip()
                    incoming_msg = incoming_msg[5:-1]
                    edge = incoming_msg
                    print("incoming message: " + incoming_msg)
                    if incoming_msg not in incomingMessages:
                        incomingMessages.append(incoming_msg)
                    msg_types[incoming_msg] = "nonstall"
                    
                    incoming = True
                    prev_message = incoming_msg

                if("msg := " in lines[i]):
                    outgoing_msg = lines[i]
                    outgoing_msg = outgoing_msg.split(',')[1]
                    print("outgoing message: " + outgoing_msg)
                    if outgoing_msg not in outgoingMessages:
                        outgoingMessages.append(outgoing_msg)

                if("Send" in lines[i]):
                    incoming = False

                if "cbe.State :=" in lines[i]:
                    outState = lines[i].strip()[13:-1]
                    key = G.add_edge(inState, outState, edge)
                    G.edges[inState, outState, edge]["message"] = edge
                    print(outState)
                i += 1

            print("finished messages for this state")

            #check for conflicts in this state
            print("all messages:")
            print(msg_types)
            keys = list(msg_types.keys())
            conflictNum = 0

            if len(keys) > 1:
                for j in range(len(keys)-1):
                    m1 = keys[j]
                    m1_type = msg_types[m1]

                    for k in range(j+1, len(keys)):
                        m2 = keys[k]
                        m2_type = msg_types[m2]

                        if(m1_type != m2_type):
                            if(not (m1,m2) in conflicts and not (m2,m1) in conflicts):
                                print("appending {} {}".format(m1, m2))
                                conflicts.append((m1, m2))
                                conflictNum += 1
            
            print("Number of new conflict in state: " + str(conflictNum))

for msg in messageTypes:
    if (msg not in incomingMessages and msg not in outgoingMessages):
        outgoingMessages.append(msg)

print("original conflicts: " + str(len(conflicts)))
assignNetwork(messageTypes, conflicts)
print("")
print("INCOMING {}".format(incomingMessages))
print("OUTGOING {}".format(outgoingMessages))
print("BOTH")
for msg in messageTypes:
    if (msg in incomingMessages and msg in outgoingMessages):
        print(msg)
print("\n")
newConflicts = []
outOnly = []
for msg in messageTypes:
        if msg in outgoingMessages and msg not in incomingMessages:
            outOnly.append(msg)

for (m1, m2) in conflicts:
    conflicting = True

    if m1 in outOnly or m2 in outOnly:
        conflicting = False

    if conflicting:
        newConflicts.append((m1, m2))

print("omitting incoming/outgoing non-conflicts: {} conflicts left".format(str(len(newConflicts))))
print("newConflicts Length {}".format(len(newConflicts)))
falseConflict = {}
for con in newConflicts:
    falseConflict[con] = True

#get gray from trace here
def enumNode(node):
    posMsg = []
    print(node)
    if node in stableStates:
        print("base case")
        out_edges = G.out_edges(node)
        for out_edge in out_edges:
            outMsg = G.get_edge_data(out_edge[0], out_edge[1]).keys()
            for oMsg in outMsg:
                posMsg.append(oMsg)
        return(set(posMsg))

    out_edges = G.out_edges(node)
    # print(node, out_edges)
    for out_edge in out_edges:
        curOutMsg = G.get_edge_data(out_edge[0], out_edge[1]).keys()
        for msg in curOutMsg:
            posMsg.append(msg)
        if not out_edge[0] == out_edge[1]:
            nextOutMsg = enumNode(out_edge[1])
            for msg in nextOutMsg:
                posMsg.append(msg)
    #     print(out_edge, outMsg)
    # print()
    return set(posMsg)

for n1 in G.nodes:
    print("start node: {}".format(n1))
    possibleMsgs = enumNode(n1)
    print(possibleMsgs)
    greyMsgs = []
    # for msg in incomingMessages:
    #     if msg not in possibleMsgs:
    #         greyMsgs.append(msg)
    for pm1 in possibleMsgs:
        for pm2 in possibleMsgs:
            if (pm1, pm2) in newConflicts:
                falseConflict[(pm1, pm2)] = False
                print("True conflict {} {}".format(pm1, pm2))
            elif (pm2, pm1) in newConflicts:
                falseConflict[(pm2, pm1)] = False
                print("True conflict {} {}".format(pm2, pm1))

    # print("Grey messages: {}".format(greyMsgs))

print(falseConflict)

for k in falseConflict.keys():
    if falseConflict[k] == True:
        newConflicts.remove(k)
        # print("removed conflict {}".format(k))
    else:
        pass
        # print("true conflict {}".format(k))

netConstraint = []
if len(sys.argv[1:]) == 2:
    print("=========Applying constraints...===========")
    with open(constraiantFile) as f:
        lines = f.readlines()
        for line in lines:
            if line[0] == '[':
                sameNet = line[1:-1].replace(" ", "").split(",")
                for m1 in sameNet:
                    for m2 in sameNet:
                        rmvConflict = (m1, m2)
                        if rmvConflict in newConflicts:
                            newConflicts.remove(rmvConflict)
                netConstraint.append(sameNet)
            else:
                pair = line.strip().replace(" ","").split(",")
                if (pair[0], pair[1]) in newConflicts:
                    rmvConflict = (pair[0], pair[1])
                    newConflicts.remove(rmvConflict)
                elif ((pair[1], pair[0]) in newConflicts):
                    rmvConflict = (pair[1], pair[0])
                    newConflicts.remove(rmvConflict)
print("Final number of conflicts: {}".format(len(newConflicts)))
assignNetwork(incomingMessages, newConflicts, netConstraint)
print("Outgoing Network")
print(outOnly)