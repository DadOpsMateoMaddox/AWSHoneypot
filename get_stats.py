import json
logs = open('/opt/cowrie/var/log/cowrie/cowrie.json').readlines()
ips = set()
logins = 0
success = 0
commands = 0
for l in logs:
    if 'src_ip' in l:
        try:
            ips.add(json.loads(l).get('src_ip'))
        except:
            pass
    if 'cowrie.login' in l:
        logins += 1
    if 'cowrie.login.success' in l:
        success += 1
    if 'cowrie.command.input' in l:
        commands += 1
print(f'Total events: {len(logs)}')
print(f'Unique attacker IPs: {len(ips)}')
print(f'Login attempts: {logins}')
print(f'Successful logins: {success}')
print(f'Commands executed: {commands}')
