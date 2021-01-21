from test2 import color_nodes
from test2 import color_nodes_2
conflicts = []
messageTypes = []
graph = {}
with open("./MSI.m") as f:
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

                    msg_types[incoming_msg] = "nonstall"
                    
                    incoming = True
                    prev_message = incoming_msg

                if("msg := " in lines[i]):
                    outgoing_msg = lines[i]
                if("Send" in lines[i]):
                    print("outgoing message: " + lines[i].strip())
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


print("")
print("number of conflicts: " + str(len(conflicts)))
print(conflicts)

print ('----------Creating graph------------------')
for msg in messageTypes:
    graph[msg] = []

for (m1,m2) in conflicts:
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

coloredNodes = color_nodes_2(graph)
# print(color_nodes(graph))
print ('----------Network Assignment------------------')
# print(coloredNodes)

print("Number of networks needed: ", max(coloredNodes.items())[1] + 1)

networkAssignment = []
for i in range(max(coloredNodes.items())[1] + 1):
    networkK = []
    for k in coloredNodes:
        if coloredNodes[k] == i:
            networkK.append(k)
    networkAssignment.append(networkK)

for i in range(len(networkAssignment)):
    print("Messaages in network {}: {}".format(i, networkAssignment[i]))

# print(graph)