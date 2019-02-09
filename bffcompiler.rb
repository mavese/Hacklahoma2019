#!/usr/bin/env ruby

require 'socket'
# TODO: Add functions support

# A list of allowed charachters.
ALLOWED = [
            '.', # Standard out
            ',', # Standard in
            '[', # Loop start
            ']', # Loop end
            '<', # Move back a cell
            '>', # Move ahead a cell
            '+', # Add 1 to the current cell
            '-', # Sub 1 from the current cell
            '#', # Open/close file
            '%', # Write val of current cell to file
            '!', # Read a char from file and set it as the current cell
            '@', # Open/close socket to localhost (on port 53333)
            '&', # Read 1 char from the socket and set as current cell
            '*', # Write val of current cell to socket
            '~', # goto cell[value of current cell]
            '$', # toggle character mode
            '^'  # open a server socket
          ]

def execute(filename)
  begin
    f = File.read(filename)
  rescue
    puts 'No such file.'
    exit
  end
  evaluate(f)
end

def evaluate(code)
  # cleanup the code (Remove anything not in ALLOWED) and then build a bracemap.
  code = cleanup(code.chars)
  bracemap = buildbracemap(code)
  handler = nil
  cursor = 0
  sock = nil
  serverSock = nil

  cells = [0]
  codeptr = 0
  cellptr = 0
  code_length = code.length
  cmode = true

  while codeptr < code_length
    command = code[codeptr]

    # Iterate through all the commands in the code and evaluate
    case command
    when '>' then cellptr += 1
                  cells.push(0) if cellptr == cells.length
    when '<' then cellptr = cellptr <= 0 ? 0 : cellptr - 1
    when '+' then cells[cellptr] = cells[cellptr] < 255 ? cells[cellptr] + 1 : 0
    when '-' then cells[cellptr] = cells[cellptr] > 0 ? cells[cellptr] - 1 : 255
    when '[' then if (cells[cellptr]).zero? then codeptr = bracemap[codeptr] end
    when ']' then if cells[cellptr] != 0 then codeptr = bracemap[codeptr] end
    when ',' then cells[cellptr] = $stdin.getc.ord
    when '.' then
      if cmode  
        $stdout.write cells[cellptr].chr
      else
        $stdout.write cells[cellptr].to_s
      end
    when '#' then
      if handler.nil?
        name = ""
        while cells[cellptr] != 0 do
            name = name + cells[cellptr].chr
            cellptr += 1
        end
        
        handler = File.open(name, 'r+')
        cursor = 0
      else
        handler.close
        handler = nil
      end
    when '%'
      if !handler.nil?
        handler.syswrite(cells[cellptr].chr)
      else
        $stderr.write "At #{codeptr}: ERROR - NO FILE IS OPEN\n"
        exit
      end
    when '!'
      if !handler.nil?
        if c = handler.getc
          cells[cellptr] = c[0].ord
          cursor += 1
        else
          cells[cellptr] = 0
        end
      else
        $stderr.write "At #{codeptr}: ERROR - NO FILE IS OPEN\n"
        exit
      end
    when '@'
      if sock.nil?
        name = ""
        while cells[cellptr] != 0 do
            name = name + cells[cellptr].chr
            cellptr += 1
        end

        sock = TCPSocket.new(name, 53333)
      else
        sock.close
        sock = nil
      end
    when '^'
        if serverSock.nil?
          serverSock = TCPServer.new(53333)
          sock = serverSock.accept
        else
          serverSock.close
          serverSock = nil
        end
    when '*'
      if !sock.nil?
        sock.write(cells[cellptr].chr)
      else
        $stderr.write "At #{codeptr}: ERROR - NO SOCK IS OPEN\n"
      end
    when '&'
      if !sock.nil?
        cells[cellptr] = sock.getc.ord
      else
        $stderr.write "At #{codeptr}: ERROR - NO SOCK IS OPEN\n"
      end
    when '~'
      if cells[cellptr] < code_length
        codeptr = cells[cellptr] - 1
      else
        $stderr.write "At #{codeptr}: ERROR - CELL VALUE OUT OF RANGE\n"
      end
    when '$'
      if !cmode then cmode = true else cmode = false end
    end

    codeptr += 1
  end
end

def cleanup(code)
  code.select { |a| ALLOWED.include? a }
end

def buildbracemap(code)
  temp_bracestack = []
  bracemap = {}
  code.each_with_index do |command, position|
    if command == '['
      temp_bracestack.push(position)
    elsif command == ']'
      start = temp_bracestack.pop
      bracemap[start] = position
      bracemap[position] = start
    end
  end
  bracemap
end

def main
  if ARGV.length == 1
    execute(ARGV[0])
  else
    puts "Usage: #{File.basename($PROGRAM_NAME)} filename"
  end
end

main
exit