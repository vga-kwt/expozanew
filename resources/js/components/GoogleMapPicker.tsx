import { useCallback, useEffect, useRef, useState } from 'react';
import { GoogleMap, Marker, useJsApiLoader } from '@react-google-maps/api';

const containerStyle = {
    width: '100%',
    height: '350px',
    borderRadius: '8px',
};

const defaultCenter = {
    lat: 29.3759,
    lng: 47.9774,
};

function toValidLatLng(latIn: unknown, lngIn: unknown): { lat: number; lng: number } {
    const parse = (v: unknown, defaultVal: number): number => {
        if (typeof v === 'number' && Number.isFinite(v)) return v;
        if (typeof v === 'string' && v.trim() !== '') {
            const n = Number(v);
            if (Number.isFinite(n)) return n;
        }
        return defaultVal;
    };
    const lat = parse(latIn, defaultCenter.lat);
    const lng = parse(lngIn, defaultCenter.lng);
    return {
        lat: Number(Math.max(-90, Math.min(90, lat))),
        lng: Number(Math.max(-180, Math.min(180, lng))),
    };
}

type Props = {
    latitude?: number | null;
    longitude?: number | null;
    onLocationChange: (lat: number, lng: number, address?: string) => void;
    disabled?: boolean;
};

export default function GoogleMapPicker({ latitude, longitude, onLocationChange, disabled = false }: Props) {
    const apiKey = (window as any).__google_maps_api_key || '';

    const { isLoaded } = useJsApiLoader({
        googleMapsApiKey: apiKey,
    });

    const [markerPos, setMarkerPos] = useState<{ lat: number; lng: number }>(() =>
        toValidLatLng(latitude, longitude),
    );

    useEffect(() => {
        setMarkerPos(toValidLatLng(latitude, longitude));
    }, [latitude, longitude]);

    const geocoderRef = useRef<google.maps.Geocoder | null>(null);
    const initialGeocodeDoneRef = useRef(false);

    // On first load with a valid position, reverse-geocode so parent gets the address for the default/initial location
    useEffect(() => {
        if (!isLoaded || initialGeocodeDoneRef.current) return;
        const pos = toValidLatLng(markerPos.lat, markerPos.lng);
        initialGeocodeDoneRef.current = true;
        if (!geocoderRef.current) geocoderRef.current = new google.maps.Geocoder();
        geocoderRef.current.geocode({ location: { lat: pos.lat, lng: pos.lng } }, (results, status) => {
            if (status === 'OK' && results && results[0]) {
                onLocationChange(pos.lat, pos.lng, results[0].formatted_address);
            } else {
                onLocationChange(pos.lat, pos.lng, '');
            }
        });
    }, [isLoaded, markerPos.lat, markerPos.lng, onLocationChange]);

    const reverseGeocode = useCallback((lat: number, lng: number) => {
        try {
            if (!geocoderRef.current) {
                geocoderRef.current = new google.maps.Geocoder();
            }
            geocoderRef.current.geocode({ location: { lat, lng } }, (results, status) => {
                if (status === 'OK' && results && results[0]) {
                    onLocationChange(lat, lng, results[0].formatted_address);
                } else {
                    onLocationChange(lat, lng, '');
                }
            });
        } catch {
            onLocationChange(lat, lng, '');
        }
    }, [onLocationChange]);

    const handleMapClick = useCallback(
        (e: google.maps.MapMouseEvent) => {
            if (disabled) return;
            const rawLat = e.latLng?.lat();
            const rawLng = e.latLng?.lng();
            const next = toValidLatLng(
                typeof rawLat === 'number' ? rawLat : undefined,
                typeof rawLng === 'number' ? rawLng : undefined,
            );
            setMarkerPos(next);
            reverseGeocode(next.lat, next.lng);
        },
        [disabled, reverseGeocode],
    );

    if (!apiKey) {
        return (
            <div className="flex items-center justify-center rounded-lg border border-dashed p-8 text-sm text-muted-foreground">
                Google Maps API key not configured. Please set GOOGLE_MAPS_API_KEY in your .env file.
            </div>
        );
    }

    if (!isLoaded) {
        return (
            <div className="flex items-center justify-center rounded-lg border p-8 text-sm text-muted-foreground">
                Loading map...
            </div>
        );
    }

    // Always derive display position so Maps API never receives non-finite coordinates
    const displayPos = toValidLatLng(markerPos.lat, markerPos.lng);

    return (
        <GoogleMap
            mapContainerStyle={containerStyle}
            center={displayPos}
            zoom={14}
            onClick={handleMapClick}
            options={{
                streetViewControl: false,
                mapTypeControl: false,
            }}
        >
            <Marker position={displayPos} draggable={!disabled} onDragEnd={handleMapClick} />
        </GoogleMap>
    );
}
