# JMeter distributed injectors (Linux) on Kubernetes

End-to-end pattern: **JMeter slaves** run on **Linux** containers; **at least 2** injector pods always run; **up to 10** pods via the Horizontal Pod Autoscaler. A **Job** runs the **master** in non-GUI mode, discovers ready slaves via the Kubernetes API, and executes a sample test plan.

## Important: “scale when VUs reach 5”

Kubernetes **HPA does not read JMeter thread counts**. This lab uses **CPU-based HPA** as a practical default: when slaves get hotter under load, the cluster adds replicas (capped at 10). Tune `averageUtilization` and slave `resources.requests.cpu` so behavior feels right for your scripts.

To scale **exactly** on “average active threads per slave > 5”, you need a **custom metric** (for example **JMeter Backend Listener → Prometheus** + **KEDA** Prometheus scaler). See `keda-prometheus-scaledobject.yaml.example` and comments inside.

## Threading model (recommended)

In distributed JMeter, **each slave runs a full copy of the test plan** unless you shard explicitly. To target **~5 concurrent users per slave**:

- Keep **threads per slave** at **5** in the Thread Group (or use a property and pass `-Jthreads=5` from the master Job).
- Increase **replica count** (via HPA) to add aggregate capacity: `total nominal users ≈ 5 × replicas` (before tuning).

## Prerequisites

- Kubernetes cluster (Docker Desktop is fine).
- `kubectl` context pointing at the cluster.
- **Metrics Server** for CPU HPA (Docker Desktop often needs it enabled, or install upstream [metrics-server](https://github.com/kubernetes-sigs/metrics-server) and allow insecure TLS for local kubelet if required).

## Deploy

```bash
kubectl apply -f k8s/jmeter/
kubectl wait -n jmeter --for=condition=ready pod -l app=jmeter-slave --timeout=180s
kubectl get pods,hpa -n jmeter
```

## Run a distributed test (master Job)

The Job waits for **at least two** ready slaves, builds the `-R` list from pod IPs, then runs `jmeter -n`.

```bash
kubectl delete job -n jmeter jmeter-master --ignore-not-found
kubectl apply -f k8s/jmeter/06-job-master.yaml
kubectl logs -n jmeter job/jmeter-master -f
```

## Autoscaling (HPA)

- **Min replicas:** 2  
- **Max replicas:** 10  
- **Metric:** average CPU % across slaves (`HorizontalPodAutoscaler` → `StatefulSet/jmeter-slave`)

Inspect:

```bash
kubectl describe hpa -n jmeter jmeter-slave
```

## Teardown

```bash
kubectl delete namespace jmeter
```

## Images (Linux)

- Slaves: `justb4/jmeter` (Debian/Ubuntu-based JMeter image).
- Master Job: `eclipse-temurin:21-jre-noble` + install `curl`, `jq`, and Apache JMeter at runtime (first run downloads the tarball; acceptable for a lab).
