import sys
from test2 import color_nodes
from test2 import color_nodes_2
from assignNetwork import assignNetwork
conflicts = []
messageTypes = []
incomingMessages = []
outgoingMessages = []
graph = {}

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

    while(not "----RevMurphi.MurphiModular.StateMachines.GenMessageStateMachines" in lines[line_idx]):
        # print(i, lines[i])
        line_idx += 1

    for i in range(line_idx, len(lines)):
        #find switch cbe.State then find inmsg.mtype
        if ("case cache" in lines[i]): #don't need to check directory or "case directory" in lines[i]
            print("state: " + lines[i].strip())
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
                            # print("conflict found")
                            # print("m1 " + m1)
                            # print("m2 " + m2)
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
#putAckBool = ("Put_Ack" in m1) or ("Put_Ack" in m2)
#invBool = ("Inv" in m1) and ("Inv" in m2)
#dataBool1 = ("DL1C1" in m1) and ("Inv_Ack" in m2)
#dataBool2 = ("DL1C1" in m2) and ("Inv_Ack" in m1)

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




# print(incomingMessages)
# print(outgoingMessages)
# for msg in messageTypes:
#     if (msg in incomingMessages and msg in outgoingMessages):
#         print(msg)


# write result to new file
# new_file = ("new" + file)
# with open(file) as f:
#     line_idx = 0
#     lines = f.readlines()
#     with open(new_file, "w") as f1:
#         line = lines[line_idx]
#         while(not "--RevMurphi.MurphiModular.GenVars" in line):
#             f1.write(line)
#             line_idx += 1
#             line = lines[line_idx]
#         f1.write(line)
#         line_idx += 1
#         line = lines[line_idx]
        
#         for i in range(networkNum):
#             f1.write("      network_{}: NET_Ordered;\n".format(i))
#             f1.write("      cnt_network_{}: NET_Ordered_cnt;\n".format(i))
        
#         f1.write("\n")

#         for i in range(networkNum):
#             f1.write("      buf_network_{}: NET_FIFO;\n".format(i))

#         f1.write("\n")

#         while(not "g_access: Access_Machine;" in line):
#             line_idx += 1
#             line = lines[line_idx]

#         while(not "procedure Reset_buf_();" in line):
#             f1.write(line)
#             line_idx += 1
#             line = lines[line_idx]

#         f1.write(lines[line_idx])
#         line_idx += 1
#         line = lines[line_idx]
#         f1.write(lines[line_idx])

#         for i in range(networkNum):
#             f1.write("      for i:Machines do\n")
#             f1.write("        undefine buf_network_{}[i].Queue;\n".format(i))
#             f1.write("        buf_network_{}[i].QueueInd:=0;\n".format(i))
#             f1.write("      endfor;\n")
#             f1.write("\n")
        
#         f1.write("\n    end;")

#         while(not "----RevMurphi.MurphiModular.Functions.GenNetworkFunc" in line):
#             line_idx += 1
#             line = lines[line_idx]

#         f1.write("\n\n\n" + line)
#         line_idx += 1


# print(graph)