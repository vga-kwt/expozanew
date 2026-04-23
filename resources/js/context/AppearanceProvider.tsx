import React, { createContext, useCallback, useEffect, useState } from 'react';

export type Appearance = 'light' | 'dark';

interface AppearanceContextType {
    appearance: Appearance;
    updateAppearance: (mode: Appearance) => void;
}

export const AppearanceContext = createContext<AppearanceContextType | undefined>(undefined);

export const AppearanceProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [appearance, setAppearance] = useState<Appearance>(() => {
        if (typeof window !== 'undefined') {
            const saved = localStorage.getItem('appearance') as Appearance | null;
            return saved === 'dark' ? 'dark' : 'light';
        }
        return 'light';
    });

    const updateAppearance = useCallback((mode: Appearance) => {
        setAppearance(mode);
        localStorage.setItem('appearance', mode);
        document.documentElement.classList.toggle('dark', mode === 'dark');
    }, []);

    useEffect(() => {
        document.documentElement.classList.toggle('dark', appearance === 'dark');
    }, [appearance]);

    return <AppearanceContext.Provider value={{ appearance, updateAppearance }}>{children}</AppearanceContext.Provider>;
};
