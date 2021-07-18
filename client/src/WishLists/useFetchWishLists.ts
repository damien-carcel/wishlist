import { useEffect, useState } from 'react';
import { createHeaders, url } from './api';

export const useFetchWishLists = () => {
  const [wishLists, setWishLists] = useState<string>('');
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  useEffect(() => {
    const fetchWishLists = async () => {
      try {
        setLoading(true);
        const response = await fetch(url('/api/wishlists'), {
          headers: createHeaders(),
          method: 'GET',
          mode: 'cors',
        });

        if (response.status >= 400 && response.status < 600) {
          setError(new Error(`Bad response from the server (status ${response.status})!`));
        }

        const wishLists = await response.json();

        setLoading(false);

        setWishLists(wishLists);
      } catch (error) {
        setError(error);
      }
    };

    fetchWishLists();
  }, []);

  return { wishLists: wishLists, error, loading };
};
