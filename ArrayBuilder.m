classdef ArrayBuilder<handle
	%数组累加器
	%将数据向内存中积累时，经常遇到需要不断累加数组的问题，MATLAB会提示预分配内存。但如果读取之前无法得知将会有多少项，预分配就会变成一个十分麻烦的动态任务。本类建立一个增长维度，在此维度上可以不断累加一个内置的数组。用户只需不断Append即可，无需考虑内存分配的问题，本类会自动进行优化的内存管理。
	properties(Access=private)
		Storage
		Capacity(1,1)uint32=0
		Subs(1,:)cell
	end
	properties(SetAccess=private)
		%当前在累加维度上的累加数
		Stock(1,1)uint32=0
	end
	properties(SetAccess=immutable)
		%累加维度
		BuildDimension(1,1)double
	end
	methods
		function obj = ArrayBuilder(BuildDimension)
			%输入参数：BuildDimension(1,1)uint8=1，累加维度
			arguments
				BuildDimension(1,1)uint8=1
			end
			obj.BuildDimension=BuildDimension;
		end
		function Append(obj,New)
			%输入参数：New，累加内容。所有累加内容在累加维度上尺寸可以不一致，但在其它维度上必须一致。
			persistent Size
			if isempty(Size)
				Size=num2cell(size(New));
			end
			if obj.Stock==0
				obj.Subs=repmat({':'},1,max(ndims(New),obj.BuildDimension));
				obj.Stock=size(New,obj.BuildDimension);
				obj.Capacity=obj.Stock*2;
				obj.Storage=cat(obj.BuildDimension,New,New);
			else
				NewStock=obj.Stock+size(New,obj.BuildDimension);
				if NewStock>=obj.Capacity
					obj.Capacity=NewStock*2;
					Size{obj.BuildDimension}=obj.Capacity;
					obj.Storage(Size{:})=New(1);
				end
				obj.Subs{obj.BuildDimension}=obj.Stock+1:NewStock;
				obj.Storage(obj.Subs{:})=New;
				obj.Stock=NewStock;
			end
		end
		function Array=Harvest(obj)
			%收获累加完毕的MATLAB数组。收获后可以释放本对象，也可以继续累加。
			obj.Subs{obj.BuildDimension}=1:obj.Stock;
			Array=obj.Storage(obj.Subs{:});
		end
	end
end