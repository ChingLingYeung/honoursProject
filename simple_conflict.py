import sys
from test2 import color_nodes
from test2 import color_nodes_2
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
        print(m1, m2)
        if(m1 == 'GetML1C1' or m2 == 'GetML1C1'):
            print("TEST {} {}".format(m1, m2))
        m1Inc = m1 in incomingMessages
        m2Inc = m2 in incomingMessages
        # if(m1Inc ^ m2Inc):
        #     conflicts.remove((m1,m2))
        #     print("{}, {} not conflicting".format(m1, m2))
        if((m1 in incomingMessages) ^ (m2 in incomingMessages)):
            # conflicts.remove((m1,m2))
            conflicting = False
            print("{}, {} not conflicting".format(m1, m2))

    if conflicting:
        newConflicts.append((m1, m2))

print(count)




print("")
print("number of conflicts: " + str(len(newConflicts)))
print(newConflicts)

print ('----------Creating graph------------------')
for msg in messageTypes:
    graph[msg] = []

for (m1,m2) in newConflicts:
    if graph[m1] == []:
        graph[m1] = [m2]
    else:
        graph[m1].append(m2)
    
    if graph[m2] == []:
        graph[m2] = [m1]
    else:
        graph[m2].append(m1)

for key in graph.keys():
    print(key, graph[key])

coloredNodes = color_nodes(graph)
# print(color_nodes(graph))
print ('----------Network Assignment------------------')
# print(coloredNodes)
networkNum = max(coloredNodes.values()) + 1

print("Number of networks needed: ", networkNum)

networkAssignment = []
for i in range(networkNum):
    networkK = []
    for k in coloredNodes:
        if coloredNodes[k] == i:
            networkK.append(k)
    networkAssignment.append(networkK)

for i in range(len(networkAssignment)):
    print("Messaages in network {}: {}".format(i, networkAssignment[i]))

# print(incomingMessages)
# print(outgoingMessages)
# for msg in messageTypes:
#     if (msg in incomingMessages and msg in outgoingMessages):
#         print(msg)


# write result to new file
new_file = ("new" + file)
with open(file) as f:
    line_idx = 0
    lines = f.readlines()
    with open(new_file, "w") as f1:
        line = lines[line_idx]
        while(not "--RevMurphi.MurphiModular.GenVars" in line):
            f1.write(line)
            line_idx += 1
            line = lines[line_idx]
        f1.write(line)
        line_idx += 1
        line = lines[line_idx]
        
        for i in range(networkNum):
            f1.write("      network_{}: NET_Ordered;\n".format(i))
            f1.write("      cnt_network_{}: NET_Ordered_cnt;\n".format(i))
        
        f1.write("\n")

        for i in range(networkNum):
            f1.write("      buf_network_{}: NET_FIFO;\n".format(i))

        f1.write("\n")

        while(not "g_access: Access_Machine;" in line):
            line_idx += 1
            line = lines[line_idx]

        while(not "procedure Reset_buf_();" in line):
            f1.write(line)
            line_idx += 1
            line = lines[line_idx]

        f1.write(lines[line_idx])
        line_idx += 1
        line = lines[line_idx]
        f1.write(lines[line_idx])

        for i in range(networkNum):
            f1.write("      for i:Machines do\n")
            f1.write("        undefine buf_network_{}[i].Queue;\n".format(i))
            f1.write("        buf_network_{}[i].QueueInd:=0;\n".format(i))
            f1.write("      endfor;\n")
            f1.write("\n")
        
        f1.write("\n    end;")


# print(graph)