from test2 import color_nodes
from test2 import color_nodes_2
from graphColouring import graphColouring
def assignNetwork(nodes, conflictList, constraints=[]):
    conflictGraph = {}
    messageTypes = nodes
    print ('----------Creating graph------------------')
    for msg in messageTypes:
        conflictGraph[msg] = []

    for (m1,m2) in conflictList:
        if conflictGraph[m1] == []:
            conflictGraph[m1] = [m2]
        else:
            conflictGraph[m1].append(m2)
        
        if conflictGraph[m2] == []:
            conflictGraph[m2] = [m1]
        else:
            conflictGraph[m2].append(m1)

    for key in conflictGraph.keys():
        print(key, conflictGraph[key])

    coloredNodes = graphColouring(conflictGraph, constraints)
    # print(color_nodes(graph))
    print ('----------Network Assignment------------------')
    # print(coloredNodes)
    networkNum = max(coloredNodes.values()) + 1

    print("Number of networks needed: ", networkNum + 1)

    networkAssignment = []
    for i in range(networkNum):
        networkK = []
        for k in coloredNodes:
            if coloredNodes[k] == i:
                networkK.append(k)
        networkAssignment.append(networkK)

    for i in range(len(networkAssignment)):
        print("Messaages in network {}: {}".format(i, networkAssignment[i]))