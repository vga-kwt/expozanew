import React from 'react';

interface MiniLineChartProps {
  data: number[];
  width?: number;
  height?: number;
  stroke?: string;
}

export const MiniLineChart: React.FC<MiniLineChartProps> = ({
  data,
  width = 100,
  height = 32,
  stroke = '#22c55e', // Tailwind green-500
}) => {
  if (!data || data.length === 0) {
    return <svg width={width} height={height}></svg>;
  }

  const min = Math.min(...data);
  const max = Math.max(...data);
  const range = max - min || 1;
  const points = data.map((d, i) => {
    const x = (i / (data.length - 1)) * width;
    const y = height - ((d - min) / range) * (height - 4) - 2;
    return `${x},${y}`;
  });

  return (
    <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`}>
      <polyline
        fill="none"
        stroke={stroke}
        strokeWidth="2"
        points={points.join(' ')}
      />
    </svg>
  );
}; 