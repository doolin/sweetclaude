"""
Tests for sc-artifact-impl.py schema additions:
- CYC- cycle artifact
- completed_at field on issues
- velocity field on sprints
- auto-set completed_at when issue status→done
- auto-calculate velocity when sprint status→closed
"""
import subprocess
import json
import os
import tempfile
import shutil
import pytest

IMPL = os.path.join(os.path.dirname(__file__), '../../hooks/sc-artifact-impl.py')


@pytest.fixture
def project_dir():
    d = tempfile.mkdtemp()
    product_base = os.path.join(d, '.sweetclaude', 'product')
    state_base = os.path.join(d, '.sweetclaude', 'state')
    os.makedirs(product_base, exist_ok=True)
    os.makedirs(state_base, exist_ok=True)
    yield d
    shutil.rmtree(d)


def _product_base(project_dir):
    return os.path.join(project_dir, '.sweetclaude', 'product')


def _state_base(project_dir):
    return os.path.join(project_dir, '.sweetclaude', 'state')


def run_create(project_dir, entity_type, data):
    r = subprocess.run(
        ['python3', IMPL, 'create', project_dir, _product_base(project_dir),
         _state_base(project_dir), entity_type, json.dumps(data)],
        capture_output=True, text=True
    )
    return r


def run_write(project_dir, entity_id, data):
    r = subprocess.run(
        ['python3', IMPL, 'write', project_dir, _product_base(project_dir),
         _state_base(project_dir), entity_id, json.dumps(data)],
        capture_output=True, text=True
    )
    return r


def run_read(project_dir, entity_id):
    r = subprocess.run(
        ['python3', IMPL, 'read', project_dir, _product_base(project_dir),
         _state_base(project_dir), entity_id],
        capture_output=True, text=True
    )
    return r


def test_create_cycle_artifact(project_dir):
    r = run_create(project_dir, 'cycle', {
        'title': 'Cycle 1', 'duration_weeks': 6, 'goal': 'Ship pitch A'
    })
    assert r.returncode == 0, r.stderr
    out = json.loads(r.stdout)
    assert out['id'].startswith('CYC-'), f"Expected CYC- prefix, got {out['id']}"


def test_issue_has_completed_at_field(project_dir):
    r = run_create(project_dir, 'issue', {'title': 'Test issue'})
    assert r.returncode == 0, r.stderr
    create_out = json.loads(r.stdout)
    issue_id = create_out['id']
    read_r = run_read(project_dir, issue_id)
    assert read_r.returncode == 0, read_r.stderr
    out = json.loads(read_r.stdout)
    assert 'completed_at' in out, "Issue template missing completed_at field"
    assert out['completed_at'] is None


def test_sprint_has_velocity_field(project_dir):
    r = run_create(project_dir, 'sprint', {'title': 'Sprint 1', 'goal': 'Ship'})
    assert r.returncode == 0, r.stderr
    create_out = json.loads(r.stdout)
    sprint_id = create_out['id']
    read_r = run_read(project_dir, sprint_id)
    assert read_r.returncode == 0, read_r.stderr
    out = json.loads(read_r.stdout)
    assert 'velocity' in out, "Sprint template missing velocity field"
    assert out['velocity'] is None


def test_close_issue_sets_completed_at(project_dir):
    create = run_create(project_dir, 'issue', {'title': 'Test'})
    assert create.returncode == 0, create.stderr
    issue_id = json.loads(create.stdout)['id']
    close = run_write(project_dir, issue_id, {'status': 'done'})
    assert close.returncode == 0, close.stderr
    read_r = run_read(project_dir, issue_id)
    assert read_r.returncode == 0, read_r.stderr
    out = json.loads(read_r.stdout)
    assert out['completed_at'] is not None, "completed_at not set when issue closed"


def test_close_sprint_calculates_velocity(project_dir):
    sprint = run_create(project_dir, 'sprint', {'title': 'Sprint 1', 'goal': 'Ship'})
    assert sprint.returncode == 0, sprint.stderr
    sprint_id = json.loads(sprint.stdout)['id']
    for i in range(3):
        run_create(project_dir, 'issue', {
            'title': f'Issue {i}', 'sprint_id': sprint_id,
            'status': 'done', 'story_points': 2
        })
    close = run_write(project_dir, sprint_id, {'status': 'closed'})
    assert close.returncode == 0, close.stderr
    read_r = run_read(project_dir, sprint_id)
    assert read_r.returncode == 0, read_r.stderr
    out = json.loads(read_r.stdout)
    assert out['velocity'] == 6, f"Expected velocity=6, got {out['velocity']}"


def test_velocity_counts_issues_linked_via_op_write(project_dir):
    sprint = run_create(project_dir, 'sprint', {'title': 'Sprint 2', 'goal': 'Ship'})
    assert sprint.returncode == 0, sprint.stderr
    sprint_id = json.loads(sprint.stdout)['id']

    issue = run_create(project_dir, 'issue', {'title': 'Late-assigned issue', 'story_points': 3})
    assert issue.returncode == 0, issue.stderr
    issue_id = json.loads(issue.stdout)['id']

    assign = run_write(project_dir, issue_id, {'sprint_id': sprint_id, 'status': 'done'})
    assert assign.returncode == 0, assign.stderr

    close = run_write(project_dir, sprint_id, {'status': 'closed'})
    assert close.returncode == 0, close.stderr

    read_r = run_read(project_dir, sprint_id)
    assert read_r.returncode == 0, read_r.stderr
    out = json.loads(read_r.stdout)
    assert out['velocity'] == 3, f"Expected velocity=3, got {out['velocity']}"


def test_create_done_issue_sets_completed_at(project_dir):
    r = run_create(project_dir, 'issue', {'title': 'Already done', 'status': 'done'})
    assert r.returncode == 0, r.stderr
    issue_id = json.loads(r.stdout)['id']
    read_r = run_read(project_dir, issue_id)
    assert read_r.returncode == 0, read_r.stderr
    out = json.loads(read_r.stdout)
    assert out.get('completed_at') not in (None, '(none)'), \
        f"completed_at should be set when issue created with status=done, got {out.get('completed_at')}"


def test_velocity_counts_legacy_sprint_key(project_dir):
    sprint = run_create(project_dir, 'sprint', {'title': 'Sprint Legacy', 'goal': 'Ship'})
    assert sprint.returncode == 0, sprint.stderr
    sprint_id = json.loads(sprint.stdout)['id']

    issue = run_create(project_dir, 'issue', {
        'title': 'Legacy issue', 'sprint_id': sprint_id,
        'status': 'done', 'story_points': 1
    })
    assert issue.returncode == 0, issue.stderr
    issue_id = json.loads(issue.stdout)['id']

    # Find the issue file on disk and rewrite so the sprint field key is 'sprint'
    # (not 'sprint_id'), simulating a legacy file written with the old **Sprint:** heading.
    import glob as _glob
    import re as _re
    issues_dir = os.path.join(_product_base(project_dir), 'issues')
    matches = _glob.glob(os.path.join(issues_dir, f'{issue_id}-*.md'))
    assert matches, f"Issue file not found for {issue_id}"
    issue_file = matches[0]
    with open(issue_file, encoding='utf-8') as fh:
        content = fh.read()
    # Ensure the key is written as **Sprint:** (legacy bare key, parses to 'sprint')
    # Replace any **Sprint Id:** or **Sprint_id:** variants with **Sprint:**
    content = _re.sub(r'\*\*Sprint[_ ]?[Ii]d:\*\*', '**Sprint:**', content)
    with open(issue_file, 'w', encoding='utf-8') as fh:
        fh.write(content)

    close = run_write(project_dir, sprint_id, {'status': 'closed'})
    assert close.returncode == 0, close.stderr

    read_r = run_read(project_dir, sprint_id)
    assert read_r.returncode == 0, read_r.stderr
    out = json.loads(read_r.stdout)
    assert out['velocity'] == 1, f"Expected velocity=1, got {out['velocity']}"
