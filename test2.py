# taken from https://codereview.stackexchange.com/questions/203319/greedy-graph-coloring-in-python

def color_nodes(graph):
  # Order nodes in descending degree
  nodes = sorted(list(graph.keys()), key=lambda x: len(graph[x]), reverse=True)
  color_map = {}

  for node in nodes:
    available_colors = [True] * len(nodes)
    for neighbor in graph[node]:
      if neighbor in color_map:
        color = color_map[neighbor]
        available_colors[color] = False
    for color, available in enumerate(available_colors):
      if available:
        color_map[node] = color
        break

  return color_map

def color_nodes_2(graph):
    color_map = {}
    # Consider nodes in descending degree 
    for node in sorted(graph, key=lambda x: len(graph[x]), reverse=True):
        neighbor_colors = set(color_map.get(neigh) for neigh in graph[node])
        color_map[node] = next( 
            color for color in range(len(graph)) if color not in neighbor_colors
        )
    return color_map

if __name__ == '__main__':
  graph = {
    'a': list('cefghi'),
    'b': list('cefghi'),
    'c': list('abefg'),
    'd': list(''),
    'e': list('abc'),
    'f': list('abc'),
    'g': list('abc'),
    'h': list('ab'),
    'i': list('ab')
  }
  print(color_nodes(graph))
  # {'c': 0, 'a': 1, 'd': 2, 'e': 1, 'b': 2, 'f': 2}
# a messageTypes['FwdGetS'] = ['DirData0', 'DirData', "OwnData", "InvAck", "LastInvAck", "Inv"]
# b messageTypes['FwdGetM'] = ['DirData0', 'DirData', "OwnData", "InvAck", "LastInvAck", "Inv"]
# c messageTypes['Inv'] = ['DirData0', 'DirData', "OwnData", "FwdGetS", 'FwdGetM']
# d messageTypes['PutAck'] = []
# e messageTypes['DirData0'] = ['Inv', 'FwdGetS', 'FwdGetM']
# f messageTypes['DirData'] = ['Inv', 'FwdGetS', 'FwdGetM']
# g messageTypes['OwnData'] = ['Inv', 'FwdGetS', 'FwdGetM']
# h messageTypes['InvAck'] = ['FwdGetS', 'FwdGetM']
# i messageTypes['LastInvAck'] = ['FwdGetS', 'FwdGetM']