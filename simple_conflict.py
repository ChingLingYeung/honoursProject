import sys
from test2 import color_nodes
from test2 import color_nodes_2
from assignNetwork import assignNetwork
conflicts = []
messageTypes = []
incomingMessages = []
outgoingMessages = []
graph = {}

assert len(sys.argv[1:]) == 1, "Too many arguments"
file = sys.argv[1]

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
                    print("outgoing message: " + outgoing_msg + str(i))
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
                            print("conflict found")
                            print("m1 " + m1)
                            print("m2 " + m2)
                            if(not (m1,m2) in conflicts and not (m2,m1) in conflicts):
                                print("appending")
                                conflicts.append((m1, m2))
                                conflictNum += 1
            
            print("Number of new conflict in state: " + str(conflictNum))

for msg in messageTypes:
    if (msg not in incomingMessages and msg not in outgoingMessages):
        outgoingMessages.append(msg)

print("original conflicts: " + str(len(conflicts)))
assignNetwork(messageTypes, conflicts)
print("")
print(messageTypes)
print("INCOMING")
print(incomingMessages)
print("OUTGOING")
print(outgoingMessages)
for msg in messageTypes:
    if (msg in incomingMessages and msg in outgoingMessages):
        print(msg)

count = 0
newConflicts = []
for (m1, m2) in conflicts:
    count += 1
    conflicting = True

    m1Type = (m1 in incomingMessages) ^ (m1 in outgoingMessages)
    m2Type = (m2 in incomingMessages) ^ (m2 in outgoingMessages)

    if(m1Type and m2Type):
        m1Inc = m1 in incomingMessages
        m2Inc = m2 in incomingMessages

        if((m1 in incomingMessages) ^ (m2 in incomingMessages)):
            conflicting = False
            print("{}, {} not conflicting".format(m1, m2))

    if conflicting:
        newConflicts.append((m1, m2))

print("omitting incoming/outgoing non-conflicts: " + str(len(newConflicts)))
assignNetwork(messageTypes, newConflicts)
# print(newConflicts)

print("=========using addtional info from table===========")
bookConflicts = []
for (m1,m2) in newConflicts:
    conflict = True
    #putack and fwd
    putAckBool = ("Put_Ack" in m1) or ("Put_Ack" in m2)
    invBool = ("Inv" in m1) and ("Inv" in m2)
    dataBool1 = ("DL1C1" in m1) and ("Inv_Ack" in m2)
    dataBool2 = ("DL1C1" in m2) and ("Inv_Ack" in m1)

    # constraintBool = ("InvL1C1" in m1 and "Fwd" in m2) or ("InvL1C1" in m2 and "Fwd" in m1)

    if(putAckBool or invBool or dataBool1 or dataBool2): # or constraintBool
        conflict = False

    if(conflict):
        bookConflicts.append((m1, m2))
print("Separating stall and 'grey' in book (theoretical): " + str(len(bookConflicts)))
# print(bookConflicts)
assignNetwork(messageTypes, bookConflicts)



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