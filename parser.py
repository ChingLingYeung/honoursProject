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

        if ("case cache" in lines[i]): #don't need to check directory or "case directory" in lines[i]
            print("state: " + lines[i].strip())
            i += 1

            incoming = False

            prev_message = ""

            msg_types = {}

            while(not "endswitch;" in lines[i]):
                # msg = ""
                # network = ""

                if("case" in lines[i]):
                    incoming_msg = lines[i].strip()
                    incoming_msg = incoming_msg[5:]
                    print("incoming message: " + incoming_msg)

                    # statistics
                    # if (not incoming_msg in msgs_stalls):
                    #     msgs_stalls[incoming_msg] = 0
                    # if (not incoming_msg in msgs_count):
                    #     msgs_count[incoming_msg] = 1
                    # else:
                    #     msgs_count[incoming_msg] = msgs_count[incoming_msg] + 1

                    if(incoming):
                        # msgs_stalls[prev_message] = msgs_stalls[prev_message] + 1
                        msg_types[prev_message] = "stall"
                    # else:
                    #     msgs_stalls[incoming_msg] = msgs_stalls[incoming_msg] + 1
                    
                    incoming = True
                    prev_message = incoming_msg
                if("msg := " in lines[i]):
                    outgoing_msg = lines[i]
                if("Send" in lines[i]):
                    print("outgoing message: " + lines[i].strip())
                    msg_types[prev_message] = "nonstall"
                    incoming = False
                    # print(lines[i][10:])
                    # network = lines[i][10:]
                    # msg_types[msg] = network
                i += 1

            if (not prev_message in msg_types):
                msg_types[prev_message] = "stall"
            print("finished messages for this state")

            #check for conflicts in this state
            print("all messages:")
            print(msg_types)
            keys = list(msg_types.keys())

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
                            conflicts.append((m1, m2))


print("")
print("number of conflicts: " + str(len(conflicts)))
print(conflicts)
# print("number of occurence of messages")
# for msg in msgs_count:
#     print(msg + " " + str(msgs_count.get(msg)))

# print("")
# print("number of stalls for all messages")
# for msg in msgs_stalls:
#     print(msg + " " + str(msgs_stalls.get(msg)))
# print(msgs_stalls)
