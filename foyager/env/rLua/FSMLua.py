import luaparser.ast as ast
from luaparser.astnodes import *
import string
import random

'''
	Converts lua code to an event-driven finite state machine (substitute for coroutines)
	- Splits functions into multiple functions, seperated by async events
	- Async events defined by finish(foo()) calls
	- Handles events inside conditional and loop blocks
'''


class EventFSMTreeGenerator:
	def __init__(self):
		pass

	def add_node(self):
		pass

	def construct_function():
		pass

	def render():
		pass

class EventFSMVisitor:
	def __init__(self):
		self.reconstructed_tree = None
		self._function_name_stack = []

	def generate_event_name(self):
		return ''.join(random.choices(string.ascii_uppercase + string.digits, k=5))

	def visit_Function(self, node):
		self._function_name_stack.append(node.name.id)
		self.visit(node.body)
		self._function_name_stack.pop()

	def visit_Call(self, node):
		print(node)
		# if isinstance(node.func, Id):
		if node.func.id == 'finish' and len(self._function_name_stack) > 0:
				func_name = self._function_name_stack[-1]

				next_event_name = self.generate_event_name()
				next_event_func_name = next_event_name + "_event_func"

				# Store the next event in the pointers
				print(f"global.event_ptrs['{func_name}'] = {next_event_func_name}")
				print(f"global.event_names['{next_event_func_name}'] = generate_event_name()")
				print(f"script.on_event(global.events['{next_event_func_name}'], function () {next_event_func_name}() end)")

				# Generate the next event function
				print(f"function {next_event_func_name}()")
				for arg in node.args:
						# if isinstance(arg, FuncCall):
					print(f"    {arg.func.id}()")
				print("end")

	def visit(self, node):
		method = 'visit_' + node.__class__.__name__
		visitor = getattr(self, method, self.generic_visit)
		return visitor(node)

	def generic_visit(self, node):
		if isinstance(node, list):
			for item in node:
				self.visit(item)
		elif isinstance(node, Node):
			# visit all object public attributes:
			children = [
				attr for attr in node.__dict__.keys() if not attr.startswith("_")
			]
			for child in children:
				self.visit(node.__dict__[child])



# Given Lua source code
source_code = """
function doThing()
		bar()
		finish(foo())
		bar()
end
"""

# Convert the source code to an AST
tree = ast.parse(source_code)

# Construct the new tree generator
tree_generator = EventFSMTreeGenerator()

# Walk the AST
visitor = EventFSMVisitor(tree_generator)
visitor.visit(tree)
