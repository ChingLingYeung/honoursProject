# adapted from https://codereview.stackexchange.com/questions/203319/greedy-graph-coloring-in-python

def graphColouring(graph, constraints):
  # Order nodes in descending degree
  nodes = sorted(list(graph.keys()), key=lambda x: len(graph[x]), reverse=True)
  color_map = {}

  for node in nodes:
    available_colors = [True] * len(nodes)
    for constraint in constraints:
        if node in constraint:
            for constNode in constraint:
                if constNode in color_map:
                    color_map[node] = color_map[constNode]
    if node in color_map:
        continue
    for neighbor in graph[node]:
      if neighbor in color_map:
        color = color_map[neighbor]
        available_colors[color] = False
    for color, available in enumerate(available_colors):
      if available:
        color_map[node] = color
        break
#   print(color_map)
  return color_map