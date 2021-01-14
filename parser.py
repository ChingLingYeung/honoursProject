msgs_count = {}
msgs_stalls = {}
conflicts = []
with open("./MSI.m") as f:
    lines = f.readlines()

    line_idx = 0

    while(not "----RevMurphi.MurphiModular.StateMachines.GenMessageStateMachines" in lines[line_idx]):
        # print(i, lines[i])
        line_idx += 1

    print(lines[line_idx])

    for i in range(line_idx, len(lines)):

        #find switch cbe.State then find inmsg.mtype

        if ("case cache" in lines[i] or "case directory" in lines[i]):
            print("state: " + lines[i][5:])
            i += 1

            incoming = False

            prev_message = ""

            msg_types = {}

            while(not "endswitch;" in lines[i]):
                # msg = ""
                # network = ""

                if("case" in lines[i]):
                    if (not lines[i][7:-1] in msgs_stalls):
                        msgs_stalls[lines[i][7:-1]] = 0
                    
                    if (not lines[i][7:-1] in msgs_count):
                        msgs_count[lines[i][7:-1]] = 1
                    else:
                        msgs_count[lines[i][7:-1]] = msgs_count[lines[i][7:-1]] + 1

                    if(incoming):
                        msgs_stalls[prev_message] = msgs_stalls[prev_message] + 1
                        msg_types[prev_message] = "stall"
                    # else:
                    #     msgs_stalls[lines[i][7:-1]] = msgs_stalls[lines[i][7:-1]] + 1
                    incoming = True
                    prev_message = lines[i][7:-1]
                    print("incoming message: " + lines[i])
                if("msg := " in lines[i]):
                    msg = lines[i]
                if("Send" in lines[i]):
                    print("outgoing message: " + lines[i])
                    msg_types[prev_message] = "nonstall"
                    # print(lines[i][10:])
                    # network = lines[i][10:]
                    # msg_types[msg] = network
                i += 1
            print("finished messages for this state")

            #check for conflicts in this state
            print(msg_types)
            keys = list(msg_types.keys())

            if len(keys) > 1:
                for j in range(len(keys)-1):
                    print(keys[j])
                    m1 = keys[j]
                    m1_type = msg_types[m1]
                    print("m1 " + m1)

                    for k in range(j+1, len(keys)):
                        m2 = keys[k]
                        m2_type = msg_types[m2]
                        print("m2 " + m2)

                        if(m1_type != m2_type):
                            print("conflict found")
                            conflicts.append((m1, m2))


print("")
print(conflicts)
# print("number of occurence of messages")
# for msg in msgs_count:
#     print(msg + " " + str(msgs_count.get(msg)))

# print("")
# print("number of stalls for all messages")
# for msg in msgs_stalls:
#     print(msg + " " + str(msgs_stalls.get(msg)))
# print(msgs_stalls)
