defmodule Mix.Tasks.CleanMixer.UI.ArchMapRendering.PlantUML do
  alias CleanMixer.ArchMap
  alias CleanMixer.ArchMap.Dependency
  alias CleanMixer.Metrics.MetricsMap

  alias CleanMixer.Metrics.ComponentMetrics.FanIn
  alias CleanMixer.Metrics.ComponentMetrics.FanOut
  alias CleanMixer.Metrics.ComponentMetrics.Instability

  @spec render(ArchMap.t(), MetricsMap.t()) :: String.t()
  def render(arch_map, metrics_map) do
    [
      "@startuml",
      "skinparam legend {\n FontSize 20\n }",
      "legend bottom left\n Instability = out / (in + out)\n endlegend",
      Enum.map(arch_map.components, &format_component(&1, metrics_map)),
      Enum.map(arch_map.dependencies, &format_dependency/1),
      "@enduml"
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp format_component(comp, metrics_map) do
    metrics = MetricsMap.component_metrics(metrics_map, comp)

    fan_in = metrics[FanIn]
    fan_out = metrics[FanOut]
    instability = metrics[Instability] |> Float.round(2)

    "rectangle #{sanitize(comp.name)} [ =#{comp.name} \n\n In=#{fan_in} Out=#{fan_out} I=#{instability} ]"
  end

  defp format_dependency(%Dependency{} = dep) do
    "[#{sanitize(dep.source.name)}] --> [#{sanitize(dep.target.name)}]"
  end

  defp sanitize(name) do
    name
    |> String.replace("/", "_")
    |> String.replace("-", "_")
  end
end
