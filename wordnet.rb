class WordNet
    def initialize (syn_file, hyper_file)
		
		@synsets = Hash.new
		syn_invalid = Array.new
		@hypernyms = Hash.new
		hyper_invalid = Array.new
		
		IO.foreach(syn_file) { |x|
			string = x.chomp
			if (string =~ /^id: \d+ synset: [^\s,]+(,[^\s,]+)*$/) then
				a = string.split(' ')
				if (a.size > 4) then
					syn_invalid << x
				else
					syn_id = a[1].to_i
					if !(@synsets.has_key? (syn_id)) then
						@synsets[syn_id] = a[3].split(',')
					elsif (@synsets.has_key? (syn_id))
						@synsets[syn_id] = @synsets.fetch(syn_id) + a[3].split(',')
					end
				end
			else
				syn_invalid << x
			end
		}
		
		if !(syn_invalid.empty?)
			print ("invalid synsets\n")
			syn_invalid.each { |x|
				print x
			}
			exit
		end
		
		IO.foreach(hyper_file) { |y|
			string = y.chomp
			if (string =~ /^from: \d+ to: \d+(\,\d+)*$/) then
				b = string.split(' ')
				hyper_id = b[1].to_i
				if (b.length > 4) then 
					hyper_invalid << y
				elsif
					hyper_id = b[1].to_i
					hypers = b[3].split(',')
					(0..hypers.size-1).each do |i| hypers[i] = hypers[i].to_i end
					if !(@hypernyms.has_key? (hyper_id)) then
						@hypernyms[hyper_id] = hypers
					elsif (@hypernyms.has_key? (hyper_id))
						@hypernyms[hyper_id] = @hypernyms.fetch(hyper_id) + hypers
					end
				end
			else
				hyper_invalid << y
			end
		}
		
		if !(hyper_invalid.empty?)
			print ("invalid hypernyms\n")
			hyper_invalid.each { |x|
				print x
			}
			exit
		end
	end
	
	def isnoun (noun)
		nouns = noun
		found = true	
		
		for i in 0..nouns.size - 1
			n = 0
			@synsets.each_value{|synset|
				if synset.include? (nouns[i]) then
					n = n + 1
				end
			}
			if n == 0 then
				found = false
			end
		end
		
		return found
	end
	
	def nouns
	
		num = 0
		
		@synsets.each_value{|synset|
			num = num + synset.size
		}	
		
		return num
	end
	
	def edges
	
		num = 0
		
		@hypernyms.each_value{|hypernym|
			num = num + hypernym.size
		}	
		
		return num
	end
	
	def length (v, w)
		if (v.all?{|v| !@synsets.has_key?(v)} || w.all?{|w| !@synsets.has_key?(w)}) then
			return -1
		else
			v.delete_if{|k| !@synsets.has_key?(k)}
			w.delete_if{|k| !@synsets.has_key?(k)}
			length_t = +1.0/0.0
			for i in 0..v.size-1
				for n in 0..w.size-1
					length_v = 0
					length_w = 0
					h_v = {0 => [v[i]]}
					h_w = {0 => [w[n]]}
					start_v = []
					start_v[0] = v[i]
					start_w = []
					start_w[0] = w[n]
			
					while (start_v.any?{|viH| @hypernyms.has_key?(viH)})
						a=[]	
						for x in 0..start_v.size-1
							if (@hypernyms.has_key?(start_v[x])) then
								for y in 0..@hypernyms[start_v[x]].size-1
									if !(a.include? @hypernyms[start_v[x]][y]) then
										a.push (@hypernyms[start_v[x]][y])
									end
								end
							end	
						end
			
						length_v = length_v+1
						h_v[length_v] = a
						start_v = a
					end
		
					while (start_w.any?{|wiH| @hypernyms.has_key?(wiH)})
						a=[]
						for x in 0..start_w.size-1
							if (@hypernyms.has_key?(start_w[x])) then
								for y in 0..@hypernyms[start_w[x]].size-1
									if !(a.include? @hypernyms[start_w[x]][y]) then
										a.push (@hypernyms[start_w[x]][y])
									end
								end
							end	
						end
			
						length_w = length_w+1
						h_w[length_w] = a
						start_w = a
					end
	
					a_CA = Hash.new([])
					for x in 0..h_v.size-1
						for y in 0..h_w.size-1
							dup = h_v[x]&h_w[y]
							a_CA[x+y] = a_CA[x+y] + dup
						end
					end
		
					a_CA.delete_if{|key,value| value.empty?}
		
					if length_t > a_CA.keys[0] then
						length_t = a_CA.keys[0]
					end
				end
			end
			return length_t
		end
	end
	
	def ancestor (v, w)
		if (v.all?{|v| !@synsets.has_key?(v)} || w.all?{|w| !@synsets.has_key?(w)}) then
			return -1
		else
			v.delete_if{|k| !@synsets.has_key?(k)}
			w.delete_if{|k| !@synsets.has_key?(k)}
			length_t = +1.0/0.0
			a_LCA = Hash.new([])
			for i in 0..v.size-1
				for n in 0..w.size-1
					length_v = 0
					length_w = 0
					h_v = {0 => [v[i]]}
					h_w = {0 => [w[n]]}
					start_v = []
					start_v[0] = v[i]
					start_w = []
					start_w[0] = w[n]
			
					while (start_v.any?{|viH| @hypernyms.has_key?(viH)})
						a=[]	
						for x in 0..start_v.size-1
							if (@hypernyms.has_key?(start_v[x])) then
								for y in 0..@hypernyms[start_v[x]].size-1
									if !(a.include? @hypernyms[start_v[x]][y]) then
										a.push (@hypernyms[start_v[x]][y])
									end
								end
							end	
						end
			
						length_v = length_v+1
						h_v[length_v] = a
						start_v = a
					end
		
					while (start_w.any?{|wiH| @hypernyms.has_key?(wiH)})
						a=[]
						for x in 0..start_w.size-1
							if (@hypernyms.has_key?(start_w[x])) then
								for y in 0..@hypernyms[start_w[x]].size-1
									if !(a.include? @hypernyms[start_w[x]][y]) then
										a.push (@hypernyms[start_w[x]][y])
									end
								end
							end	
						end
			
						length_w = length_w+1
						h_w[length_w] = a
						start_w = a
					end
	
					a_CA = Hash.new([])
					for x in 0..h_v.size-1
						for y in 0..h_w.size-1
							dup = h_v[x]&h_w[y]
							a_CA[x+y] = a_CA[x+y] + dup
						end
					end
					
					a_CA.delete_if{|key,value| value.empty?}
					if (length_t > a_CA.keys[0]) then
						length_t = a_CA.keys[0]
						a_LCA[length_t] = a_LCA[length_t] + a_CA[length_t]
					elsif (length_t == a_CA.keys[0])
						a_LCA[length_t] = a_LCA[length_t] + a_CA[length_t]
					end
				end
			end
			a_LCA = a_LCA.sort.to_h
			return a_LCA.values[0].uniq
		end
	end
	
	def root (v, w)
		v_a = Array.new
		w_a = Array.new	
		@synsets.each{|key, value|
			if (value.include?(v)) then
				v_a.push(key)
			end
			if (value.include?(w)) then
				w_a.push(key)
			end
		}
		
		if (v_a.empty?||w_a.empty?) then
			return -1
		elsif (v_a.all?{|v_a| !@synsets.has_key?(v_a)} || w_a.all?{|w_a| !@synsets.has_key?(w_a)}) then
			return -1
		else
			v_a.delete_if{|k| !@synsets.has_key?(k)}
			w_a.delete_if{|k| !@synsets.has_key?(k)}
			length_t = +1.0/0.0
			a_LCA = Hash.new([])
			for i in 0..v_a.size-1
				for n in 0..w_a.size-1
					length_v = 0
					length_w = 0
					h_v = {0 => [v_a[i]]}
					h_w = {0 => [w_a[n]]}
					start_v = []
					start_v[0] = v_a[i]
					start_w = []
					start_w[0] = w_a[n]
			
					while (start_v.any?{|viH| @hypernyms.has_key?(viH)})
						a=[]	
						for x in 0..start_v.size-1
							if (@hypernyms.has_key?(start_v[x])) then
								for y in 0..@hypernyms[start_v[x]].size-1
									if !(a.include? @hypernyms[start_v[x]][y]) then
										a.push (@hypernyms[start_v[x]][y])
									end
								end
							end	
						end
			
						length_v = length_v+1
						h_v[length_v] = a
						start_v = a
					end
		
					while (start_w.any?{|wiH| @hypernyms.has_key?(wiH)})
						a=[]
						for x in 0..start_w.size-1
							if (@hypernyms.has_key?(start_w[x])) then
								for y in 0..@hypernyms[start_w[x]].size-1
									if !(a.include? @hypernyms[start_w[x]][y]) then
										a.push (@hypernyms[start_w[x]][y])
									end
								end
							end	
						end
			
						length_w = length_w+1
						h_w[length_w] = a
						start_w = a
					end
	
					a_CA = Hash.new([])
					for x in 0..h_v.size-1
						for y in 0..h_w.size-1
							dup = h_v[x]&h_w[y]
							a_CA[x+y] = a_CA[x+y] + dup
						end
					end
					
					a_CA.delete_if{|key,value| value.empty?}
					
					if (length_t > a_CA.keys[0]) then
						length_t = a_CA.keys[0]
						a_LCA[length_t] = a_LCA[length_t] + a_CA[length_t]
					elsif (length_t == a_CA.keys[0])
						a_LCA[length_t] = a_LCA[length_t] + a_CA[length_t]
					end
				end
			end
			a_LCA = a_LCA.sort.to_h
			a_LCA_root = []
			for i in 0..a_LCA.values[0].size-1
				a_LCA_root = a_LCA_root+@synsets[a_LCA.values[0][i]]
			end
			return a_LCA_root
		end
	end
	
	def outcast (nouns)
		h_nouns = Hash.new()
		for i in 0..nouns.size-1
			@synsets.each{|key, value|
			if (value.include?(nouns[i])) then
				if h_nouns[nouns[i]].nil? then
					h_nouns[nouns[i]] = [key]
				elsif !h_nouns[nouns[i]].include?(key)
					h_nouns[nouns[i]].push(key)
				end
			end
			}
		end
		
		t_d = Hash.new(0)
		for i in 0..h_nouns.size-1
			for n in 0..nouns.size-1
				t_d[h_nouns.keys[i]] = t_d[h_nouns.keys[i]] + length(h_nouns.values[i], h_nouns[nouns[n]]) ** 2
			end
		end
		
		outcast  = []
		t_d.each{|k,v| 
			if v == t_d.values.max then
				outcast.push(k)
			end
		}
		
		outcasts = []
		for i in 0..nouns.size-1
			if outcast.include?(nouns[i]) then
				outcasts.push (nouns[i])
			end
		end
		
		return outcasts
	end
	
end

#If the result is an array, then the array's contents will be printed in a sorted and space-delimited string. 
#Otherwise, the result is printed as-is
def print_res(res)
    if (res.instance_of? Array) then 
        str = ""
        res.sort.each {|elem| str += elem.to_s + " "}
        puts str.chomp
    else 
        puts res
    end
end 

#Checks that the user has provided an appropriate amount of arguments
if (ARGV.length < 3 || ARGV.length > 5) then
  fail "usage: wordnet.rb <synsets file> <hypersets file> <command> <input file>"
end

synsets_file = ARGV[0]
hypernyms_file = ARGV[1]
command = ARGV[2]
input_file = ARGV[3]

wordnet = WordNet.new(synsets_file, hypernyms_file)

#Refers to number of lines in input file
commands_with_0_input = %w(edges nouns)
commands_with_1_input = %w(isnoun outcast)
commands_with_2_input = %w(length ancestor)

#Executes the program according to the provided mode
case command
when *commands_with_0_input
	puts wordnet.send(command)
when *commands_with_1_input 
	file = File.open(input_file)
	nouns = file.gets.split(/\s/)
	file.close    
    print_res(wordnet.send(command, nouns))
when *commands_with_2_input 
	file = File.open(input_file)   
	v = file.gets.split(/\s/).map(&:to_i)
	w = file.gets.split(/\s/).map(&:to_i)
	file.close
    print_res(wordnet.send(command, v, w))
when "root"
	file = File.open(input_file)
	v = file.gets.strip
	w = file.gets.strip
	file.close
    print_res(wordnet.send(command, v, w))
else
  fail "Invalid command"
end