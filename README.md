# nagios-checks for HAProxy Backend Pools

This script connects to a HA Proxy Stats page, parses the backend pools, and returns a nagios status.

"Usage: $0 <haproxy_stats_url> <filter_group_name>"

Returns:
0 = OK

1 = Warning

2 = Critical

Examples:


$ 'get-haproxy-pool-status.sh'
Usage: get-haproxy-pool-status.sh <haproxy_stats_url> <filter_group_name>


All nodes up (returns OK):
$ 'get-haproxy-pool-status.sh' 'http://URL:PORT/stats' BACKEND_POOL_NAME
Status: 0 - BACKEND_POOL_NAME is up


One or more nodes down (returns WARNING)
$ 'get-haproxy-pool-status.sh' 'http://URL:PORT/stats' BACKEND_POOL_NAME
Status: 1 - plt-demo32-ui-203,DOWN;plt-demo32-ui-32,UP;BACKEND,UP;

All nodes down (returns CRITICAL)
$ 'get-haproxy-pool-status.sh' 'http://URL:PORT/stats' BACKEND_POOL_NAME
Status: 2 - Pool BACKEND_POOL_NAME DOWN: NODE1,DOWN;NODE2,DOWN;BACKEND,DOWN
