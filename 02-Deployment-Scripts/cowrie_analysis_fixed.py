import pandas as pd
import json
import matplotlib.pyplot as plt

# --- CONFIGURATION ---
log_file = 'cowrie.json' 
split_date = '2025-10-15'
# ---------------------

data = []
with open(log_file, 'r') as f:
    for line in f:
        try:
            data.append(json.loads(line))
        except:
            continue

df = pd.DataFrame(data)
df['timestamp'] = pd.to_datetime(df['timestamp'])

before_df = df[df['timestamp'] < split_date]
after_df = df[df['timestamp'] >= split_date]

def analyze_period(frame, label):
    if len(frame) == 0:
        return {"Label": label, "Total Events": 0, "Unique IPs": 0, "Success Rate": 0, "Avg Commands/Session": 0}
    
    total_events = len(frame)
    unique_ips = frame['src_ip'].nunique() if 'src_ip' in frame.columns else 0
    
    login_attempts = frame[frame['eventid'].str.contains('login', na=False)] if 'eventid' in frame.columns else pd.DataFrame()
    successful_logins = frame[frame['eventid'] == 'cowrie.login.success'] if 'eventid' in frame.columns else pd.DataFrame()
    success_rate = (len(successful_logins) / len(login_attempts)) * 100 if len(login_attempts) > 0 else 0
    
    commands = frame[frame['eventid'] == 'cowrie.command.input'] if 'eventid' in frame.columns else pd.DataFrame()
    sessions = frame['session'].nunique() if 'session' in frame.columns else 0
    cmd_per_session = len(commands) / sessions if sessions > 0 else 0
    
    return {
        "Label": label,
        "Total Events": total_events,
        "Unique IPs": unique_ips,
        "Success Rate": round(success_rate, 2),
        "Avg Commands/Session": round(cmd_per_session, 2)
    }

stats_before = analyze_period(before_df, "Default Config")
stats_after = analyze_period(after_df, "Custom Config")

comparison = pd.DataFrame([stats_before, stats_after])
print("=== DATA FOR GAMMA SLIDE ===")
print(comparison)

metrics = ['Total Events', 'Unique IPs', 'Success Rate']
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
for i, metric in enumerate(metrics):
    axes[i].bar(comparison['Label'], comparison[metric], color=['#ff9999', '#66b3ff'])
    axes[i].set_title(metric)
plt.tight_layout()
plt.show()
