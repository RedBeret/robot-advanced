"""Custom listener that collects test metrics and generates an HTML report.

Usage:
    robot --listener libraries/MetricsCollector.py tests/
"""

import time
import json
from pathlib import Path


class MetricsCollector:
    """Collect detailed test metrics and generate a dashboard report."""

    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self, output_file: str = "metrics_report.html"):
        self._output_file = output_file
        self._suites = []
        self._current_suite = None
        self._current_test_start = None
        self._metrics = {
            "total": 0, "passed": 0, "failed": 0, "skipped": 0,
            "total_duration": 0, "tests": [], "slowest": None,
        }

    def start_suite(self, data, result):
        self._current_suite = data.name

    def start_test(self, data, result):
        self._current_test_start = time.time()

    def end_test(self, data, result):
        duration = time.time() - self._current_test_start
        self._metrics["total"] += 1
        self._metrics["total_duration"] += duration

        test_info = {
            "name": data.name,
            "suite": self._current_suite,
            "status": result.status,
            "duration": round(duration, 3),
            "tags": list(data.tags),
            "message": result.message or "",
        }

        if result.status == "PASS":
            self._metrics["passed"] += 1
        elif result.status == "FAIL":
            self._metrics["failed"] += 1
        else:
            self._metrics["skipped"] += 1

        if not self._metrics["slowest"] or duration > self._metrics["slowest"]["duration"]:
            self._metrics["slowest"] = test_info

        self._metrics["tests"].append(test_info)

    def close(self):
        self._generate_report()

    def _generate_report(self):
        m = self._metrics
        pass_rate = (m["passed"] / m["total"] * 100) if m["total"] > 0 else 0
        avg_duration = (m["total_duration"] / m["total"]) if m["total"] > 0 else 0

        tests_html = ""
        for t in sorted(m["tests"], key=lambda x: -x["duration"]):
            color = "#22c55e" if t["status"] == "PASS" else "#ef4444"
            bar_width = min(t["duration"] / max(avg_duration * 3, 0.001) * 100, 100)
            tests_html += f"""
            <tr>
                <td>{t['suite']}</td>
                <td>{t['name']}</td>
                <td style="color:{color};font-weight:bold">{t['status']}</td>
                <td>{t['duration']}s</td>
                <td><div style="background:{color};height:8px;width:{bar_width}%;border-radius:4px"></div></td>
            </tr>"""

        html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Test Metrics Dashboard</title>
<style>
body {{ font-family: -apple-system, sans-serif; margin: 2rem; background: #0f172a; color: #e2e8f0; }}
.cards {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin: 1.5rem 0; }}
.card {{ background: #1e293b; padding: 1.5rem; border-radius: 12px; text-align: center; }}
.card .value {{ font-size: 2.5rem; font-weight: bold; }}
.card .label {{ font-size: 0.85rem; color: #94a3b8; margin-top: 0.5rem; }}
table {{ width: 100%; border-collapse: collapse; margin-top: 1.5rem; }}
th, td {{ padding: 0.75rem 1rem; text-align: left; border-bottom: 1px solid #334155; }}
th {{ background: #1e293b; color: #94a3b8; font-size: 0.8rem; text-transform: uppercase; }}
h1 {{ color: #f8fafc; }}
</style></head><body>
<h1>Test Metrics Dashboard</h1>
<div class="cards">
  <div class="card"><div class="value">{m['total']}</div><div class="label">Total Tests</div></div>
  <div class="card"><div class="value" style="color:#22c55e">{m['passed']}</div><div class="label">Passed</div></div>
  <div class="card"><div class="value" style="color:#ef4444">{m['failed']}</div><div class="label">Failed</div></div>
  <div class="card"><div class="value">{pass_rate:.1f}%</div><div class="label">Pass Rate</div></div>
</div>
<div class="cards">
  <div class="card"><div class="value">{m['total_duration']:.1f}s</div><div class="label">Total Duration</div></div>
  <div class="card"><div class="value">{avg_duration:.2f}s</div><div class="label">Avg Duration</div></div>
  <div class="card"><div class="value">{m['slowest']['duration']:.2f}s</div><div class="label">Slowest Test</div></div>
  <div class="card"><div class="value">{len(set(t['suite'] for t in m['tests']))}</div><div class="label">Suites</div></div>
</div>
<table>
<tr><th>Suite</th><th>Test</th><th>Status</th><th>Duration</th><th>Timeline</th></tr>
{tests_html}
</table>
</body></html>"""

        Path(self._output_file).write_text(html)
        print(f"\n>>> Metrics dashboard: {self._output_file}")
