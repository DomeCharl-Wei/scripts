" socket server
" port 51423
" operation:
" at normal mode
"   ;si -- server initialize
"   ;cm -- check messages
"   ;sm -- show messages
"   ;sh -- server halt
"   ;sr + msg -- server reply client msg
"   ;st + host + msg -- send msg to host

if exists('g:loaded_socket_server')
	finish
endif

let g:loaded_socket_server = 1
let g:current_message = ""
python << EOF
import socket
import select
import re
import vim
server_host = ""
server_port = 51423
current_msg = ''
socks = ''

#def server_init(host, port):
def server_init(host, port):
    global server_start_flags
    server_start_flags = False
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    bindaddr = (host, port)
    s.bind(bindaddr)
    server_start_flags = True
    print "Server is running on port %d" % port
    return s

def check_msg(desc):
    (sread, swrite, sexc) = select.select(desc, [], [], 0)
    print "Have %d message(s)" % len(sread)
    return sread

def show_msg():
    (sread, swrite, sexc) = select.select(desc, [], [], 0)
    if len(sread) == 0:
        print "no message"
        return False
    for sock in sread:
        global current_client
        data, addr = sock.recvfrom(1024)
        current_client = addr
        print "from '%s:%d' :\n" % (addr[0], addr[1])
        print "%s" % data
    return True

def server_halt(sock):
    sock.close()
    print "server halted"

def server_reply(addr, msg):
    return send_to(addr, msg)
    
def send_to(addr, msg):
    newsock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    newsock.connect(addr)
    newsock.sendall(msg);
    print "send message successfully"
    newsock.close()
    return True
EOF

function! ServerInit()
python << EOF
socks = server_init(server_host, server_port)
EOF
endfunction

function! CheckMsg()
python << EOF
descs = [socks]
check_msg(descs)
EOF
endfunction

function! ShowMsg()
python << EOF
show_msg()
EOF
endfunction

function! ServerHalt()
python << EOF
server_halt(socks)
EOF
endfunction

function! ServerReply(vim_msg)
python << EOF
current_msg = vim.eval('a:vim_msg')
#current_client = ('192.168.122.20', 51423)
print current_client
if current_client:
    server_reply(current_client, current_msg)
else:
    print "please start server first"
EOF
endfunction

function! SendTo(vim_msg)
python << EOF
if server_start_flags:
    current_msg = vim.eval('a:vim_msg')
    tmp = current_msg.split(' ')

    # verify IP address format
    pattern0 = '^[1-9]+.[0-9]+.[0-9]+.[0-9]+'
    res = re.match(pattern0, tmp[0])
    if res and res.group() == tmp[0]:
        pattern1 = '^[1-9]+.[0-9]+.[0-9]+.[0-9]+:[0-9]+'
        res1 = re.match(pattern1, tmp[0])
        if res1 and res.group() == tmp[0]:
            ip = tmp[0].split(':')[0]
            port = tmp[0].split(':')[1]
            addr = (ip, int(port))
        else:
            addr = (tmp[0], 51423)
    else:
        print "Invalid Host Format"
        return False

    # process messages
    del tmp[0]
    sendstr = ' '.join(tmp)
    send_to(addr, sendstr)
else:
    print "please start server first"
    return False
return True
EOF
endfunction


nmap <silent> ;si : call ServerInit()<CR>
nmap <silent> ;cm : call CheckMsg()<CR>
nmap <silent> ;sm : call ShowMsg()<CR>
nmap <silent> ;sh : call ServerHalt()<CR>
if !exists(':ServerReply')
    command -nargs=1 ServerReply : call ServerReply(<f-args>)
endif
nmap <silent> ;sr :ServerReply 

if !exists(':SendTo')
    command -nargs=1 SendTo : call SendTo(<f-args>)
endif
nmap <silent> ;st :SendTo 
